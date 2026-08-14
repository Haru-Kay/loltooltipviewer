$missingIcons ||= []
$missingValues ||= []

module AugmentCache
  def self.load
    @@augments = {}

    if File.exist?("Data/mayhem.dat")
      @@augments = load_data("Data/mayhem.dat")
      return
    end

    queue = Queue.new
    data = nil
    File.open("Data/augments.json", 'rb') { |f| data = JSON.parse(f.read) }

    data.each { |e| queue << e }

    threads = 5.times.map {
      Thread.new {
        until queue.empty?
          begin
            augment = queue.pop(true)
          rescue ThreadError
            break
          end

          name = augment["apiName"]
          aug = Augment.new(augment)
          @@augments.store(name, aug)
          #self.class.define_method(name) { @@augments[name] }

          iconpath = aug.icon
          iconpath = iconpath.downcase[...-4]
          cachename = iconpath.split("/")[-1]
          img = nil

          if !File.exist?("Graphics/Images/" + iconpath + ".png")
            iconpath = "https://raw.communitydragon.org/pbe/game/" + iconpath + ".png"
            uri = URI(iconpath)
            Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|

              http.request(Net::HTTP::Get.new(uri)) do |response|
                if response.is_a?(Net::HTTPSuccess)
                  img = response.read_body
                  #puts 'Successfully got file'
                else
                  puts "FAILED TO FETCH FILE: #{response.code} #{response.message}"
                  $missingIcons.push(cachename)
                  aug.icons = [
                    "ASSETS/UX/Kiwi/Augments/Icons/GenericAbilityAugmentIcon_#{aug.rarity}.tex",
                    "ASSETS/UX/Kiwi/Augments/Icons/GenericAbilityAugmentIcon_#{aug.rarity}.tex"
                  ]
                end
              end
            end

            File.binwrite("Graphics/Images/" + cachename + ".png", img)
          end
        end
      }
    }

    threads.each(&:join)
  end

  def self.save
    save_data(@@augments, "Data/mayhem.dat")
  end

  def self.augments
    return @@augments
  end

  def self.[](value)
    if value.is_a?(Numeric)
      return @@augments.find { |_, v| v.id == value } || @@augments.values[value]
    end
    if value.is_a?(String) || value.is_a?(Symbol)
      value = value.to_s
      value = value[1..] if value.start_with?("@")
      return @@augments[value]
    end
    return nil
  end

  def self.method_missing(method, *args, &block)
    if @@augments.respond_to?(method)
      @@augments.send(method, *args, &block)
    else
      super
    end
  end

  def self.respond_to_missing?(method, include_private = false)
    @@augments.respond_to?(method) || super
  end
end
