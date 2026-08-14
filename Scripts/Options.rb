class Window_PokemonOption < Window_DrawableCommand
  attr_reader :mustUpdateOptions
  attr_accessor :options

  NAME_COLOR = :Orange2
  SEL_COLOR = :Red2
  BACK_COLOR = :Gray2
  HEAD_COLOR = :ShardBlue

  def initialize(options, x, y, width, height)
    @options = options
    @optvalues = []
    @mustUpdateOptions = false
    for i in 0...@options.length
      @optvalues[i] = 0
    end
    super(x, y, width, height)
  end

  def [](i)
    return @optvalues[i]
  end

  def []=(i, value)
    @optvalues[i] = value
    refresh
  end

  def itemCount
    return @options.length
  end

  def atSectionHeader?
    return @options[self.index].is_a?(String) && self.index != @options.length - 1
  end

  def drawItem(index, count, rect)
    colorarrays = isDarkWindowskin(self.windowskin) ? ColorArrays : LightColorArrays
    rect = drawCursor(index, rect)
    if @options[index].is_a?(String) # Headers and 'Back'
      colors = index == @options.length - 1 ? colorarrays[BACK_COLOR] : colorarrays[HEAD_COLOR]
      optionname = @options[index]
      startX = rect.x
      optionwidth = Graphics.width
    else
      colors = colorarrays[NAME_COLOR]
      optionname = @options[index].name
      offset = 8
      startX = rect.x + offset
      optionwidth = ((rect.width - offset) * 9.5 / 20)
    end
    drawShadowText(self.contents, startX, rect.y, optionwidth, rect.height, optionname, *colors)
    self.contents.draw_text(startX, rect.y, optionwidth, rect.height, optionname)
    return if @options[index].is_a?(String)

    sel_colors = colorarrays[SEL_COLOR]
    if @options[index].is_a?(EnumOption)
      if @options[index].values.length > 1
        totalwidth = 0
        for value in @options[index].values
          totalwidth += self.contents.text_size(value).width
        end
        spacing = (optionwidth - totalwidth) / (@options[index].values.length - 1)
        spacing = 0 if spacing < 0
        xpos = optionwidth + startX
        ivalue = 0
        for value in @options[index].values
          colors = ivalue == self[index] ? sel_colors : [self.baseColor, self.shadowColor]
          drawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value, *colors)
          self.contents.draw_text(xpos, rect.y, optionwidth, rect.height, value)
          xpos += self.contents.text_size(value).width
          xpos += spacing
          ivalue += 1
        end
      else
        colors = [self.baseColor, self.shadowColor]
        drawShadowText(self.contents, startX + optionwidth, rect.y, optionwidth, rect.height, optionname, *colors)
      end
    elsif @options[index].is_a?(NumberOption)
      value = @options[index].format.call(@options[index].optstart + self[index])
      xpos = optionwidth + startX
      drawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value, *sel_colors)
    else
      value = @options[index].values[self[index]]
      xpos = optionwidth + startX
      drawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value, *sel_colors)
      self.contents.draw_text(xpos, rect.y, optionwidth, rect.height, value)
    end
  end

  def update
    oldindex = self.index

    if Input.repeat?(Input::DOWN)
      self.index += 1
      self.index += 1 while atSectionHeader?
      self.index = 0 if self.index > @options.length - 1
      self.index += 1 while atSectionHeader?
    elsif Input.repeat?(Input::UP)
      self.index -= 1
      self.index -= 1 while atSectionHeader?
      self.index = @options.length - 1 if self.index < 0
      self.index -= 1 while atSectionHeader?
    elsif Input.repeat?(Input::R)
      self.index += 8 # page size
      self.index -= 1 while atSectionHeader? || self.index > @options.length - 1
    elsif Input.repeat?(Input::L)
      self.index -= 8 # page size
      self.index += 1 while atSectionHeader? || self.index < 0
    end

    dorefresh = self.index != oldindex

    if self.active && !@options[self.index].is_a?(String)
      if Input.repeat?(Input::LEFT) || Input.repeat?(Input::RIGHT)
        oldvalue = @options[self.index].get
        self[self.index] = Input.repeat?(Input::LEFT) ?
          @options[self.index].prev(self[self.index]) :
          @options[self.index].next(self[self.index])
        newvalue = @options[self.index].get
        dorefresh = true if oldvalue != newvalue
      end
    end

    @mustUpdateOptions = dorefresh
    if dorefresh
      refresh
    end
  end
end

module PropertyMixin
  def get
    @getProc ? @getProc.call() : nil
  end

  def set(value)
    @setProc.call(value) if @setProc
  end
end

class EnumOption
  include PropertyMixin
  attr_reader :values
  attr_reader :name
  attr_reader :description

  def initialize(name, options, getProc, setProc, description = "")
    @values = options
    @name = name
    @getProc = getProc
    @setProc = setProc
    @description = description
  end

  def next(current)
    index = current + 1
    index = @values.length - 1 if index > @values.length - 1
    self.set(index)
    return index
  end

  def prev(current)
    index = current - 1
    index = 0 if index < 0
    self.set(index)
    return index
  end

  def current(index)
  end
end

class NumberOption
  include PropertyMixin
  attr_reader :name
  attr_reader :format
  attr_reader :optstart
  attr_reader :optinc
  attr_reader :description

  def initialize(name, format, optstart, optend, optinc, getProc, setProc, description = "")
    @name = name
    @format = format
    @optstart = optstart
    @optend = optend
    @optinc = optinc
    @getProc = getProc
    @setProc = setProc
    @description = description
  end

  def next(current)
    index = current + @optstart
    index += @optinc
    if index > @optend
      index = @optstart
    end
    self.set(index - @optstart)
    return index - @optstart
  end

  def prev(current)
    index = current + @optstart
    index -= @optinc
    if index < @optstart
      index = @optend
    end
    self.set(index - @optstart)
    return index - @optstart
  end

  def current(index)
  end
end

def settingToTextSpeed(speed)
  return 2 if speed == 0
  return 1 if speed == 1
  return -2 if speed == 2
  return MessageConfig::TextSpeed if MessageConfig::TextSpeed

  return Graphics.frame_rate > 40 ? -2 : 1
end

module MessageConfig
  def self.defaultSystemFrame
    return resolveBitmap("Graphics/UI/" + TextFrames[$Settings.frame]) || ""
  end

  def self.defaultSpeechFrame
    return resolveBitmap("Graphics/Windowskins/" + SpeechFrames[$Settings.textskin]) || ""
  end

  def self.defaultSystemFontName
    return MessageConfig.tryFonts(VersionStyles[0][0], "Gill Sans MT Pro", "Gill Sans MT Pro")
  end

  def self.defaultTextSpeed
    return settingToTextSpeed($Settings.textspeed)
  end

  def getSystemTextSpeed
    return $Settings.textspeed
  end
end

class Options
  attr_accessor :textspeed
  attr_accessor :textskipwait
  attr_accessor :frame
  attr_accessor :textskin
  attr_accessor :font
  attr_accessor :screensize
  attr_accessor :border

  def initialize
    fixMissingValues
  end

  def fixMissingValues
    @textspeed      = 2 if @textspeed.nil? # Text speed (0=slow, 1=mid, 2=fast)
    @textskipwait   = 1 if @textskipwait.nil? # Wait for text skip (0 is on, 1 is off)
    @frame       = 0 if @frame.nil? # Default window frame (see also TextFrames)
    @textskin    = 0 if @textskin.nil? # Speech frame
    @font        = 0 if @font.nil? # Font (see also VersionStyles)
    @screensize  = 0 if @screensize.nil? # 0=half size, 1=full size, 2=double size
    @border      = 0 if @border.nil? # Screen border (0=off, 1=on)
    @keyboard                 = 0 if @keyboard.nil? # 0 is on, 1 is off
  end

  def useKeyboard?
    return true
  end
end
