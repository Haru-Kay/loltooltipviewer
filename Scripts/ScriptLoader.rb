# The SCRIPTS constant is initialized in game's respective Bootstrap.rb file which is loaded before this one.
# Note that ScriptLoader needs to be loaded using Scripts.rxdata. Loading it using preloadScript in mkxp.json breaks F12 reset.

# macOS version of mkxp-z has the standard libraries located elsewhere but they're in load path by default.
$:.push('stdlib') unless System.platform[/macOS/]
# Fix loading of rbconfig gem.
$:.push('stdlib/x64-mingw32') if System.platform[/Windows/]
$:.push('stdlib/x86_64-linux') if System.platform[/Linux/]
$:.push('../Resources/Ruby/3.1.0/x86_64-darwin') if System.platform[/macOS/]
# Add external gems to load path.
$:.push('gems')

# Let Net::HTTP know where to look for cacert file
ENV['SSL_CERT_FILE'] = 'cacert.pem'

def dp(message)
  print(message)
end

def fileExists?(file)
  # System.file_exist? respects paths defined in "patches" directive in mkxp.json, unlike File.exist?.
  return System.file_exist?(file) if defined?(System.file_exist?)
end

class Reset < Exception
end

def criticalCode
  ret = 0
  begin
    yield
    ret = 1
  rescue Exception
    e = $!
    if e.is_a?(Reset) || e.is_a?(SystemExit)
      raise
    else
      logError(e, display: true)
      if e.is_a?(Hangup)
        ret = 2
        raise Reset.new
      end
    end
  end
  return ret
end

def logError(e, display: false, extramessage: nil)
  emessage = getExceptionshowMessage(e)
  btrace = ""
  if e.backtrace
    maxlength = true ? 25 : 10
    e.backtrace[0, maxlength].each { |i| btrace += "#{i}\n" }
  end
  message = "[#{GAME_TITLE} #{GAME_VERSION} #{Time.now}]"
  message += "\n" + extramessage if extramessage
  message += "\nException: #{e.class}\nMessage: #{emessage}\n#{btrace}\n"

  errorlog = (RTP.getSaveFileName("errorlog.txt") rescue "errorlog.txt")

  File.open(errorlog, "ab") { |f| f.write(message) }

  if display
    message += errorlog == "errorlog.txt" ?
      _INTL("This exception was logged in 'errorlog.txt' in your Game Directory.") :
      _INTL("This exception was logged in 'errorlog.txt' in your Save Directory.")
    message += "\n" + _INTL("Press Ctrl+C to copy this message to the clipboard.")
    dp(message)
  end
end

def getExceptionshowMessage(e)
  emessage = e.message
  #if e.is_a?(Hangup)
  #  emessage = "The script is taking too long. The game will restart."
  if e.is_a?(Errno::ENOENT)
    filename = emessage.sub("No such file or directory - ", "")
    emessage = "File #{filename} not found."
  end
  emessage = emessage[0, 500] if emessage.length > 500
  return emessage
end

if Dir.pwd.downcase.include?("/temp/")
  raise "extract the archive, silly"
end

def loadScript(file)
  begin
    code = File.open(file, 'r') { |f| f.read }
    # We don't want these JoiPlay hacks anymore.
    # MKXP.run_postload(code)
    # code = MKXP.apply_overrides(code)
    eval(code, nil, file)
  rescue
    logError($!, display: true)
  end
end

module ThreadLoader
  def self.startLoadingScripts
    @@scriptLoadThread = Thread.new{
      if $DEBUG
        begin
          require 'pp'
        rescue LoadError
        end
      end

      SCRIPTS.each do |path|
        next if path.nil?
        path = 'Scripts/' + path unless path.start_with?('Scripts/')
        path = path + '.rb' unless path.end_with?('.rb')
        loadScript(path)
      end
    }
  end

  def self.startLoadingCache
    @@cacheThread = Thread.new {
      $cache.load
      @@scriptLoadThread&.join
    }
  end

  def self.awaitScripts
    @@scriptLoadThread&.join
    @@scriptLoadThread = nil
    puts (Time.now - $boottime)
  end

  def self.awaitCache
    @@cacheThread&.join
    @@cacheThread = nil
  end

  def self.awaitRuntimeData
    @@augmentLoadThread&.join
    @@augmentLoadThread = nil
    puts (Time.now - $boottime)
  end
end
# Load base game scripts
INIT.each do |path|
  next if path.nil?
  path = 'Scripts/' + path unless path.start_with?('Scripts/')
  path = path + '.rb' unless path.end_with?('.rb')
  loadScript(path)
end

ThreadLoader.startLoadingScripts
ThreadLoader.awaitScripts
unless $cache
  $cache = LOLCache.new
  ThreadLoader.startLoadingCache
  ThreadLoader.awaitCache
end

$softReset = false
begin
  # Main game loop
  loop do
    retval = mainFunctionNoGraphics
    if retval == 0 # failed
      loop do
        Graphics.update
      end
    elsif retval == 1 # ended successfully
      break
    end
  end

  # Prevents game from forcibly closing after an error so you can restart using F12.
  loop do
    Graphics.update
    Input.update
  end
rescue Reset => e
  $softReset = true
  raise e
ensure
  # This code runs when the main loop is done, for instance when you try to close the game.
  # $softReset is used to detect whether this is F12 or not.
  if $updaterThread&.alive?
    # Updater thread is known to potentially hang the game if the server is slow.
    $updaterThread.kill
    $updaterThread.join(0.01)
    # Simply killing it doesn't help either because it still isn't killed immediately if it's waiting for network.
    # If the thread is still alive and we're not soft-resetting, force an os-level exit.
    exit! if !$softReset && $updaterThread.alive?
  end
end
