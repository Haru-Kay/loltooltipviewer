################################################################################
# General purpose utilities
################################################################################
def _nextComb(comb, length)
  i = comb.length - 1
  begin
    valid = true
    for j in i...comb.length
      if j == i
        comb[j] += 1
      else
        comb[j] = comb[i] + (j - i)
      end
      if comb[j] >= length
        valid = false
        break
      end
    end
    return true if valid

    i -= 1
  end while i >= 0
  return false
end

# Iterates through the array and yields each combination of _num_ elements in
# the array.
def eachCombination(array, num)
  return if array.length < num || num <= 0

  if array.length == num
    yield array
    return
  elsif num == 1
    for x in array
      yield [x]
    end
    return
  end
  currentComb = []
  arr = []
  for i in 0...num
    currentComb[i] = i
  end
  begin
    for i in 0...num
      arr[i] = array[currentComb[i]]
    end
    yield arr
  end while _nextComb(currentComb, array.length)
end

def gameGoByeByeNow
  $scene = nil
  return
end


################################################################################
# Player-related utilities, random name generator
################################################################################
def getUserNameEx()
  userName = getSystemName()
  userName = userName.gsub(/\s+.*$/, "")
  if userName.length > 0
    userName[0, 1] = userName[0, 1].upcase
    return userName
  end
  userName = userName.gsub(/\d+$/, "")
  if userName.length > 0
    userName[0, 1] = userName[0, 1].upcase
    return userName
  end
  return nil
end

def getSystemName()
  return ["Frank", "Johnathan", "Joelle", "Charlene"][rand(4)] if $Settings.streamermode && $Settings.streamermode == 1

  return System.user_name
end

def getRandomNameEx(type, variable, upper, maxLength = 100)
  return "" if maxLength <= 0

  name = ""
  50.times {
    name = ""
    formats = []
    case type
      when 0 # Names for males
        formats = %w(F5 BvE FE FE5 FEvE)
      when 1 # Names for females
        formats = %w(vE6 vEvE6 BvE6 B4 v3 vEv3 Bv3)
      when 2 # Neutral gender names
        formats = %w(WE WEU WEvE BvE BvEU BvEvE)
      else
        return ""
    end
    format = formats[rand(formats.length)]
    format.scan(/./) { |c|
      case c
        when "c" # consonant
          set = %w(b c d f g h j k l m n p r s t v w x z)
          name += set[rand(set.length)]
        when "v" # vowel
          set = %w(a a a e e e i i i o o o u u u)
          name += set[rand(set.length)]
        when "W" # beginning vowel
          set = %w( a a a e e e i i i o o o u u u au au ay ay
                    ea ea ee ee oo oo ou ou )
          name += set[rand(set.length)]
        when "U" # ending vowel
          set = %w(a a a a a e e e i i i o o o o o u u ay ay ie ie ee ue oo)
          name += set[rand(set.length)]
        when "B" # beginning consonant
          set1 = %w(b c d f g h j k l l m n n p r r s s t t v w y z)
          set2 = %w(
            bl br ch cl cr dr fr fl gl gr kh kl kr ph pl pr sc sk sl
            sm sn sp st sw th tr tw vl zh
          )
          name += rand(3) > 0 ? set1[rand(set1.length)] : set2[rand(set2.length)]
        when "E" # ending consonant
          set1 = %w(b c d f g h j k k l l m n n p r r s s t t v z)
          set2 = %w( bb bs ch cs ds fs ft gs gg ld ls
                     nd ng nk rn kt ks
                     ms ns ph pt ps sk sh sp ss st rd
                     rn rp rm rt rk ns th zh)
          name += rand(3) > 0 ? set1[rand(set1.length)] : set2[rand(set2.length)]
        when "f" # consonant and vowel
          set = %w(iz us or)
          name += set[rand(set.length)]
        when "F" # consonant and vowel
          set = %w( bo ba be bu re ro si mi zho se nya gru gruu glee gra glo ra do zo ri
                    di ze go ga pree pro po pa ka ki ku de da ma mo le la li )
          name += set[rand(set.length)]
        when "2"
          set = %w(c f g k l p r s t)
          name += set[rand(set.length)]
        when "3"
          set = %w(nka nda la li ndra sta cha chie)
          name += set[rand(set.length)]
        when "4"
          set = %w(una ona ina ita ila ala ana ia iana)
          name += set[rand(set.length)]
        when "5"
          set = %w(e e o o ius io u u ito io ius us)
          name += set[rand(set.length)]
        when "6"
          set = %w(a a a elle ine ika ina ita ila ala ana)
          name += set[rand(set.length)]
      end
    }
    break if name.length <= maxLength
  }
  name = name[0, maxLength]
  case upper
    when 0
      name = name.upcase
    when 1
      name[0, 1] = name[0, 1].upcase
  end
  if $game_variables && variable
    $game_variables[variable] = name
    $game_map.need_refresh = true if $game_map
  end
  return name
end

def getRandomName(maxLength = 100)
  return getRandomNameEx(2, nil, nil, maxLength)
end

################################################################################
# String utilities
################################################################################

class String # Console colors for strings
  def white;          "\e[0m#{self}\e[0m"  end
  def black;          "\e[30m#{self}\e[0m" end
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
  def yellow;         "\e[33m#{self}\e[0m" end
  def blue;           "\e[34m#{self}\e[0m" end
  def magenta;        "\e[35m#{self}\e[0m" end
  def cyan;           "\e[36m#{self}\e[0m" end
  def gray;           "\e[37m#{self}\e[0m" end

  def bg_black;       "\e[40m#{self}\e[0m" end
  def bg_red;         "\e[41m#{self}\e[0m" end
  def bg_green;       "\e[42m#{self}\e[0m" end
  def bg_yellow;      "\e[43m#{self}\e[0m" end
  def bg_blue;        "\e[44m#{self}\e[0m" end
  def bg_magenta;     "\e[45m#{self}\e[0m" end
  def bg_cyan;        "\e[46m#{self}\e[0m" end
  def bg_gray;        "\e[47m#{self}\e[0m" end

  def bold;           "\e[1m#{self}\e[22m" end
  def italic;         "\e[3m#{self}\e[23m" end
  def underline;      "\e[4m#{self}\e[24m" end
  def blink;          "\e[5m#{self}\e[25m" end
  def reverse_color;  "\e[7m#{self}\e[27m" end
end

def toProperCase(str)
  str = str.to_s if str.is_a?(Symbol)
  split = str.split(" ")
  ret = ""
  split.each { |s|
    ret += s[0].upcase + s[1, s.length].downcase
    ret += " " if split.length != 1
  }
  return ret
end

def getColorShadow(*color, percent: 30)
  if color[0].is_a?(Color)
    red = color[0].red
    green = color[0].green
    blue = color[0].blue
  elsif color.length == 3
    red, green, blue = color
  else
    dp("Invalid color supplied: #{color}")
    return *color
  end
  hsl = rgbToHSL(red, green, blue)
  hsl[2] *= (percent / 100.0)
  return Color.new(*hslToRGB(*hsl))
end

def rgbToHSL(red, green, blue)
  red /= 255.0
  green /= 255.0
  blue /= 255.0
  max = [red, green, blue].max
  min = [red, green, blue].min
  hue = (max + min) / 2.0
  sat = (max + min) / 2.0
  light = (max + min) / 2.0

  if (max == min)
    hue = 0
    sat = 0
  else
    d = max - min;
    sat = light >= 0.5 ? d / (2.0 - max - min) : d / (max + min)
    case max
      when red
        hue = (green - blue) / d + (green < blue ? 6.0 : 0)
      when green
        hue = (blue - red) / d + 2.0
      when blue
        hue = (red - green) / d + 4.0
    end
    hue /= 6.0
  end
  return [(hue * 360), (sat * 100), (light * 100)]
end

def hslToRGB(hue, sat, light)
  hue = hue / 360.0
  sat = sat / 100.0
  light = light / 100.0

  red = 0.0
  green = 0.0
  blue = 0.0

  if (sat == 0.0)
    red = light.to_f
    green = light.to_f
    blue = light.to_f
  else
    q = light < 0.5 ? light * (1 + sat) : light + sat - light * sat
    p = 2 * light - q
    red = hueToRGB(p, q, hue + 1 / 3.0)
    green = hueToRGB(p, q, hue)
    blue = hueToRGB(p, q, hue - 1 / 3.0)
  end

  return [(red * 255), (green * 255), (blue * 255)]
end

def hueToRGB(p, q, t)
  t += 1 if t < 0
  t -= 1                                 if t > 1
  return p + (q - p) * 6 * t             if t < 1 / 6.0
  return q                               if t < 1 / 2.0
  return p + (q - p) * (2 / 3.0 - t) * 6 if t < 2 / 3.0

  return p
end

def grayscale(col, method)
  case method
    when :L # luminance
      return (col.red * 0.2989 + col.green * 0.587 + col.blue * 0.114).floor
    when :A # average
      return ([col.red, col.green, col.blue].sum / 3).floor
    when :S # sight
      return (0.2126 * col.red + 0.7152 * col.green + 0.0722 * col.blue).floor
    else
      return col
  end
end

class Bitmap
  def pixel(x, y)
    return x + (y * self.width)
  end
end

class Color
  def to_i
    return self.alpha.to_i << 24 | self.blue.to_i << 16 | self.green.to_i << 8 | self.red.to_i
  end
end

class Integer
  def to_color
    a = self >> 24
    b = self >> 16 & 0xff
    g = self >> 8 & 0xff
    r = self & 0xff
    return Color.new(r, g, b, a)
  end
end

def deep_copy(obj)
  return Marshal.load(Marshal.dump(obj))
end

def checkStringBracketSyntax(string, key)
  stack = []
  convert = { "[" => "]", "{" => "}", "(" => ")" }
  for char in 0...string.length
    stack.push(string[char]) if string[char] == "[" || string[char] == "{" || string[char] == "("
    if string[char] == "]" || string[char] == "}" || string[char] == ")"
      if string[char] != convert[stack.last]
        raise "#{key} syntax error, check your code"
        break
      end
      stack.pop
    end
  end
  return stack.empty?
end

class TrueClass
  def to_i
    return 1
  end
end

class FalseClass
  def to_i
    return 0
  end
end

module Input
  LeftMouseKey  = 1
  RightMouseKey = 2
  F3    = 23
  F4    = 24
  F5    = 25
  PAGEUP = L
  PAGEDOWN = R
  ITEMKEYS      = [Input::F5, Input::F4, Input::F3]
  ITEMKEYSNAMES = [_INTL("F5"), _INTL("F4"), _INTL("F3")]
  F2 = :F2

  def self.getstate(button)
    self.pressex?(button)
  end

  def self.isComboKeyPressed?
    return self.pressex?(:LGUI) || self.pressex?(:RGUI) || self.pressex?(:LCTRL) || self.pressex?(:RCTRL)  || self.pressex?(:LALT) || self.pressex?(:RALT)
  end
end

module Mouse
  module_function

  # Returns the position of the mouse relative to the game window.
  def getMousePos(catch_anywhere = false)
    return nil unless Input.mouse_in_window? || catch_anywhere

    return Input.mouse_x, Input.mouse_y
  end
end

def startTimer
  $timer = Time.now
end

def stopTimer
  puts Time.now - $timer
end

def shapeBitmap(shape, size, color)
  pixels = []
  case shape
    when :CursorLeft
      width, height = size, size * 2
      for column in 0...width
        effcolumn = column - (column % 2) # We want the resolution of a pixel, not a half-pixel
        for row in (height / 2 - 1 - effcolumn)...(height / 2 + 1 + effcolumn)
          pixels.push([column, row])
        end
      end
    when :CursorRight
      width, height = size, size * 2
      for column in 0...width
        effcolumn = column - (column % 2) # We want the resolution of a pixel, not a half-pixel
        for row in (height / 2 - 1 - effcolumn)...(height / 2 + 1 + effcolumn)
          pixels.push([width - 1 - column, row]) # Simply mirroring the columns from CursorLeft
        end
      end
    when :Rect
      width, height = *size # Size should be given as an array in this case
      for column in 0...width
        for row in 0...height
          pixels.push([column, row])
        end
      end
    when :RectBorder
      width, height = *size # Size should be given as an array in this case
      for column in 0...width
        effcolumn = column - (column % 2) # Pixel resolution
        for row in 0...height
          effrow = row - (row % 2) # Pixel resolution
          pixels.push([column, row]) if [0, height - 2].include?(effrow) || [0, width - 2].include?(effcolumn)
        end
      end
  end
  bitmap = Bitmap.new(width, height)
  pixels.each { |x, y| bitmap.set_pixel(x, y, color) }
  return bitmap
end

# Takes a bitmap and returns the [x, y, width, height] values to be used to trim empty space from the edges of the bitmap
def trimmedBitmapCoords(bitmap)
  fullWidth, fullHeight = bitmap.width, bitmap.height

  usedCols = (0...fullWidth).select { |x|
    (0...fullHeight).any? { |y| bitmap.get_pixel(x, y).alpha != 0 }
  }
  usedCols = [0, fullWidth] if usedCols.empty?
  retX = usedCols.min
  retWidth = usedCols.max - retX + 1

  usedRows = (0...fullHeight).select { |y|
    (0...fullWidth).any? { |x| bitmap.get_pixel(x, y).alpha != 0 }
  }
  usedRows = [0, fullWidth] if usedRows.empty?
  retY = usedRows.min
  retHeight = usedRows.max - retY + 1

  return retX, retY, retWidth, retHeight
end

def changeCanvasSize(bitmap, size)
  width = bitmap.width
  height = bitmap.height
  offsetX = (size - width) / 2
  offsetX -= 1 if offsetX % 2 == 1
  offsetY = (size - height) / 2
  offsetY -= 1 if offsetY % 2 == 1
  resizedBitmap = Bitmap.new(size, size)
  resizedBitmap.blt(offsetX, offsetY, bitmap, bitmap.rect)

  return resizedBitmap
end

def trim(bitmap)
  raw_data = bitmap.raw_data.unpack("I*").map{ |i| i.to_color }

  width = bitmap.width
  height = bitmap.height
  bounds = { x: width, y: height, x2: 0, y2: 0}

  y = 0
  while y < height
    x = 0
    while x < width
      index = (y * bitmap.width + x).to_i
      if raw_data[index].alpha != 0
        bounds[:x] = x if x < bounds[:x]
        bounds[:y] = y if y < bounds[:y]
      end
      x += 1
    end
    y += 1
  end

  y = height - 1
  while y >= 0
    x = width - 1
    while x >= 0
      index = (y * bitmap.width + x).to_i
      if raw_data[index].alpha != 0
        bounds[:x2] = x + 1 if x > bounds[:x2]
        bounds[:y2] = y + 1 if y > bounds[:y2]
      end
      x -= 1
    end
    y -= 1
  end
  #print bounds

  newWidth = bounds[:x2] - bounds[:x]
  newHeight = bounds[:y2] - bounds[:y]
  newBitmap = Bitmap.new(newWidth,newHeight)
  rectangle = Rect.new(bounds[:x],bounds[:y],newWidth,newHeight)

  newBitmap.blt(0,0,bitmap,rectangle)

  return newBitmap
end

def resizeNearestNeighbor(bitmap, factor)
  newdata = []
  #unpack data into colors
  olddata = bitmap.raw_data.unpack("I*").map{ |i| i.to_color }

  #get new bounds for new bitmap creation
  newWidth = (bitmap.width * factor).to_i
  newHeight = (bitmap.height * factor).to_i

  #iterate through new bounds
  for y in 0...newHeight
    for x in 0...newWidth
      #calculate original x and y
      oldX = (x / factor).round
      oldY = (y / factor).round

      #calculate original index
      oldIndex = (oldY * bitmap.width + oldX).to_i

      #append
      newdata.push(olddata[oldIndex])
    end
  end

  newBitmap = Bitmap.new(newWidth, newHeight)
  #repack
  newBitmap.raw_data = newdata.map{ |c| c.to_i }.pack("I*")
  return newBitmap
end

def removeFloorName(name)
  words = name.split(" ")
  words = words[0..-2] if words.length > 1 && words[-1].match(/[0-9]F\Z/) # matches any string that ends with a number followed by an F
  return words.join(" ")
end

################################################################################
# Sprite Centering methods
################################################################################
def shiftSpritesY(sprites, i)
  normal = [freelines([sprites[0]], i, 1, 0...192), freelines([sprites[0]], i, -1, 0...192)]
  return nil if normal[0] >= 128 || normal[1] >= 96
  baseline = ((normal.sum / 2).floor / 2).floor * 2
  return 0 if baseline == normal[1]
  full = [freelines(sprites, i, 1, 0...384), freelines(sprites, i, -1, 0...384)]
  sprites.each do |sprite|
    clone = sprite.clone
    sprite.clear_rect(0, 192 * i, 384, 192)
    sprite.blt(0, 192 * i + normal.sum - baseline - (normal[0] - full[0]), clone, Rect.new(0, 192 * i + full[0], 384, 192 - full.sum))
  end
  return normal[1] - baseline
end

def freelines(sprites, i, direction, range = 0...384)
  freelines = []
  sprites.each do |sprite|
    # 1 = get freelines from the top
    # -1 = get freelines from the bottom
    # the brackets are correct!
    y = direction == -1 ? 192 * (i + 1) : 192 * i - 1
    freecounter = 0
    192.times do
      y += direction
      free = true
      for x in range
        free = false if sprite.get_pixel(x, y).alpha != 0
      end
      if free
        freecounter += 1
      else
        break
      end
    end
    freelines.push freecounter
  end
  return freelines.min
end

def shiftSpritesX(sprites, i, shiny: false)
  normal = [freecolumns([sprites[0]], i, 1, shiny: shiny), freecolumns([sprites[0]], i, -1, shiny: shiny)]
  return nil if normal[0] >= 96 || normal[1] >= 96
  offset = ((normal.sum / 2).floor / 2).floor * 2
  return 0 if offset == normal[1]
  full = [freecolumns(sprites, i, 1, shiny: shiny), freecolumns(sprites, i, -1, shiny: shiny)]
  sprites.each do |sprite|
    clone = sprite.clone
    x = shiny ? 192 : 0
    sprite.clear_rect(x, 192 * i, 192, 192)
    sprite.blt(x + normal.sum - offset - (normal[0] - full[0]), 192 * i, clone, Rect.new(x + full[0], 192 * i, 192 - full.sum, 192))
  end
  return normal[1] - offset
end

def freecolumns(sprites, i, direction, shiny: false)
  freecolumns = []
  sprites.each do |sprite|
    # 1 = get freecolumns from the left
    # -1 = get freecolumns from the right
    # the brackets are correct!
    x = direction == -1 ? 192 : -1
    x += 192 if shiny
    freecounter = 0
    192.times do
      x += direction
      free = true
      for y in (192 * i - 1)...(192 * (i + 1))
        free = false if sprite.get_pixel(x, y).alpha != 0
      end
      if free
        freecounter += 1
      else
        break
      end
    end
    freecolumns.push freecounter
  end
  return freecolumns.min
end
