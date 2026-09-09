def threadCompile(data, compilerProc)
  ret = LOLHashWrapper.new
  queue = Queue.new

  data.each { |e| queue << e }

  threads = 5.times.map {
    Thread.new {
      until queue.empty?
        begin
          entry = queue.pop(true)
        rescue ThreadError
          print $!
          break
        end
        compilerProc.call(entry, ret)
      end
    }
  }

  threads.each(&:join)
  return ret
end

def compileAugments
  data = nil
  File.open("Data/augments.json", 'rb') { |f| data = JSON.parse(f.read) }

  ret = threadCompile(data, proc { |augment, ret|
    name = augment["apiName"]
    aug = Augment.new(augment)
    #self.class.define_method(name) { ret[name] }

    iconpath = aug.icon
    iconpath = iconpath.downcase[...-4]
    cachename = iconpath.split("/")[-1]
    img = nil

    if !File.exist?("Graphics/Augments/" + cachename + ".png")
      iconpath = "https://raw.communitydragon.org/pbe/game/" + iconpath + ".png"
      img = imageFetch(iconpath)
      if img
        File.binwrite("Graphics/Augments/" + cachename + ".png", img)
        aug.icons = ["Graphics/Augments/" + cachename + ".png"]
      else
        aug.icons = [
          "Graphics/Augments/#{aug.rarity}.png"
        ]
      end
    else
      aug.icons = ["Graphics/Augments/" + cachename + ".png"]
    end

    ret.store(name, aug)
  })

  save_data(ret, "Data/mayhem.dat")
end

def compileAugmentGroups
  data = nil
  File.open("Data/groups.json", 'rb') { |f| data = JSON.parse(f.read) }

  ret = threadCompile(data.to_a, proc { |group, ret|
    name = group[0]
    obj = AugmentGroup.new(*group)
    ret.store(name, obj)
  })

  save_data(ret, "Data/mayhemGroups.dat")
end


def compileChamps
  data = nil
  File.open("Data/champions.json", 'rb') { |f| data = JSON.parse(f.read) }

  manualMap = {
    "zilean" => "chronokeeper",
    "blitzcrank" => "steamgolem",
    "chogath" => "greenterror",
    "anivia" => "cryophoenix",
    "rammus" => "armordillo",
    "orianna" => "oriana",
    "xinzhao" => "xinzhaorework"
  }
  manualMap.default_proc = proc { |h, k| k }

  ret = threadCompile(data.to_a, proc { |champ, ret|
    name = champ[0]
    c = ChampionData.new(*champ)
    ret.store(name, c)

    iconpath = "assets/characters/#{c.icon}/hud/#{manualMap[c.icon]}_square"
    img = nil

    if !File.exist?("Graphics/Champions/" + c.icon + ".png")
      path = "https://raw.communitydragon.org/pbe/game/" + iconpath + ".png"
      img = imageFetch(path)
      img ||= imageFetch("https://raw.communitydragon.org/pbe/game/" + iconpath + "_0.png")

      File.binwrite("Graphics/Champions/" + c.icon + ".png", img) unless img.nil?
    end
  })

  save_data(ret, "Data/champions.dat")
  puts "done"
end

def imageFetch(path)
  uri = URI(path)
  Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|

    http.request(Net::HTTP::Get.new(uri)) do |response|
      if response.is_a?(Net::HTTPSuccess)
        img = response.read_body
        #puts 'Successfully got file'
        return img
      else
        puts "FAILED TO FETCH FILE #{path}: #{response.code} #{response.message}"
        $missingIcons.push(path)
        return nil
      end
    end
  end
end
