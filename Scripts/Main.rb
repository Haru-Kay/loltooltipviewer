require 'net/http'
require 'json'

def mainFunction
  criticalCode { mainFunctionNoGraphics }
  return 1
end

def mainFunctionNoGraphics
  $testing = true
  $Settings = Options.new

  # Graphics.width = 1056
  # Graphics.height = 639
  # Graphics.resize_screen(Graphics.width, Graphics.height)
  # Graphics.center

  $bmpCache ||= {}
  scene = BaseScene.new
  scene.main

  return
  begin

    $t = {}


    $s = []
    oldmouse = [0, 0]
    oldscroll = 0
    augmentIndex = 0
    displayIndex = 0
    redraw = false
    n = false
    debug = false

    time = Time.now

    if debug
      $s.push(AugmentTooltip.new(AugmentCache[216], true))
      $s.push(AugmentTooltip.new(AugmentCache[220], true))
      $s[-1].y += $s[-2].y + $s[-2].height + 8
    end

    while !n
      if $s.length < AugmentCache.length && !debug
        20.times {
          break if $s.length >= AugmentCache.length
          t = AugmentTooltip.new(AugmentCache.values[augmentIndex], true)

          if !$s.empty?
            t.y += $s[-1].y + $s[-1].height + 8
          end
          $s.push(t)
          augmentIndex += 1
        }
      else
        if !$loaded
          $loaded = true
          puts Time.now - time
        end
        if Input.triggerex?(:Q)
          redraw = true
          $s.sort_by! { |t| t.augment["id"] }
        end
        if Input.triggerex?(:W)
          redraw = true
          $s.sort_by! { |t| t.augment["name"] }
        end
        if Input.triggerex?(:E)
          redraw = true
          $s.sort_by! { |t| t.augment["rarity"] }
        end
        if Input.triggerex?(:R)
          redraw = true
          $s.sort_by! { |t| t.augment["apiName"] }
        end
        if redraw
          $s.each_with_index { |t, i|
            newY = i == 0 ? 0 : ($s[i - 1].y + $s[i - 1].height + 8)
            t.y = newY
          }
          redraw = false
        end
      end

      if Input.triggerex?(:F)
        begin
          Input.text_input = true
          $past_texts = [] if !$past_texts
          code = messageFreeText("Use arrow keys for previous searches.", $past_texts[-1] || "", 999, Graphics.width, $past_texts).downcase
          $past_texts.unshift(code) unless code == ""
          $past_texts.uniq!
          search = $s[(displayIndex + 1)..].find { |f| f.augment.id.to_s == code || f.augment.name.downcase.include?(code) || f.augment.apiName.downcase.include?(code) || f.augment.tooltip.downcase.include?(code) }
          search ||= $s[0..displayIndex].find { |f| f.augment.id.to_s == code || f.augment.name.downcase.include?(code) || f.augment.apiName.downcase.include?(code) || f.augment.tooltip.downcase.include?(code) }
          if search
            i = $s.index(search)
            diff = $s[i].y - $s[displayIndex].y
            $s.each { |t| t.y -= diff }
            displayIndex = i
          else
            showMessage("No results")
          end
          Input.text_input = false
        rescue
          logError($!, display: true)
          Input.text_input = false
        end
      end


      Graphics.update
      Input.update

      mouse = Mouse::getMousePos(true)
      scroll = Input.scroll_v

      if Input.pressex?(Input::LeftMouseKey)
        realdiff = mouse[1] - oldmouse[1]
        if $s[0].y + realdiff > 0
          realdiff = 0 - $s[0].y
        end
        $s.each { |t| t.y += realdiff } if realdiff != 0
      end

      if Input.triggerex?(:DOWN)
        displayIndex = (displayIndex + 1) % $s.length
        diff = $s[displayIndex].y
        $s.each { |t| t.y -= diff }
      end
      if Input.triggerex?(:UP)
        displayIndex = (displayIndex - 1) % $s.length
        diff = 0 - $s[displayIndex].y
        $s.each { |t| t.y += diff }
      end

      if Input.triggerex?(:PAGEDOWN)
        displayIndex = (displayIndex + 5) % $s.length
        diff = $s[displayIndex].y
        $s.each { |t| t.y -= diff }
      end
      if Input.triggerex?(:PAGEUP)
        displayIndex = (displayIndex - 5) % $s.length
        diff = 0 - $s[displayIndex].y
        $s.each { |t| t.y += diff }
      end
      if scroll != oldscroll
        if $s[0].y + (16 * scroll) <= 0
          $s.each { |t| t.y += (16 * scroll) }
        end
      end

      oldmouse = mouse
      oldscroll = scroll
    end

  rescue Hangup
    raise
  end
end

def getAugmentImage(iconpath)
  iconpath = iconpath[1] if iconpath.is_a?(Array)
  iconpath = iconpath.downcase[...-4]
  cachename = iconpath.split("/")[-1]

  bitmap = AugmentIcon.new(1, 1)
  bitmap.setBitmap("Graphics/Images/" + cachename + ".png")
  bitmap.zoom_x = 64.0 / bitmap.bitmap.width
  bitmap.zoom_y = 64.0 / bitmap.bitmap.height
  return bitmap
end

def createclass(hash)
  return if !hash.is_a?(Hash)
  klazz = hash.delete("~class")
  klazz = klazz[1...].upcase if klazz.start_with?("0x")
  $t[klazz] ||= []
  keys = (hash.keys + $t[klazz]).uniq
  $t[klazz] = keys

  hash.values.each { |v|
    createsubclasses(v)
  }

  return if Object.const_defined?(klazz)
  out = "class #{klazz}\n"
  keys.each { |k|
    t = k
    t = k[1...] if k.start_with?("0x")
    out += "  attr_accessor :#{t}\n"
  }

  out += "
  def initialize(json)
    json.each { |k, v|
      next if k == \"~class\"
      if v.is_a?(Hash)
        t = v[\"~class\"]
        t = t[1...].upcase if t.start_with?(\"0x\")
        klazz = Object.const_get(t)
        v = klazz.new(v)
      end
      self.instance_variable_set(\"@\" + k, v)
    }
  end\n\n  def to_s\n\n  end\nend"
  File.open("Scripts/Tooltip/#{klazz}.rb", 'wb') { |f| f.write(out) }
end

def createsubclasses(obj)
  if obj.is_a?(Hash)
    createclass(obj)
  end
  if obj.is_a?(Array)
    obj.each { |v| createsubclasses(v) }
  end
end

class AugmentIcon < IconSprite
  def width
    return (self.bitmap.width * self.zoom_x).to_i
  end

  def height
    return (self.bitmap.height * self.zoom_y).to_i
  end
end

class AugmentTooltip2


  attr_accessor :augment
  attr_accessor :visible

  def canDraw?
    return false if @visible
    path = @augment.icon.downcase[...-4]
    cachename = path.split("/")[-1]
    return $bmpCache.key?(cachename)
  end

  def initialize(augment, visible = false)
    @visible = visible
    @augment = augment
    @sprites = {}

    draw if @visible

  end

  def draw(text = "")
    @sprites[:bg] = SpriteWindow_Base.new(0, 0, 835, 1500)
    @sprites[:bg].z = 1

    @curHeight = SPACING
    @sprites[:icon] = getAugmentImage(@augment.icon)
    @sprites[:icon].x = SPACING
    @sprites[:icon].y = @curHeight
    @sprites[:icon].z = 10
    #@sprites[:icon].bitmap.fill_rect(@sprites[:icon].bitmap.rect, Color.new(100, 100, 100))

    # @sprites[:cdIcon] = IconSprite.new(1, 1)
    # @sprites[:cdIcon].setBitmap("Graphics/Icons/cooldown.png")
    # @sprites[:cdIcon].x = @sprites[:bg].width - SPACING - @sprites[:cdIcon].bitmap.width
    # @sprites[:cdIcon].y = @curHeight + 2
    # @sprites[:cdIcon].z = 10

    # @sprites[:cdText] = BitmapSprite.new(770, 1500)
    # @sprites[:cdText].y = @curHeight
    # @sprites[:cdText].z = 10
    # setSystemFont(@sprites[:cdText].bitmap)
    # @sprites[:cdText].bitmap.font.size = 26
    # drawTextPositions(@sprites[:cdText].bitmap, [["#{cooldown[1]}s", @sprites[:cdIcon].x - SPACING, 0, :right, Color.new(205, 190, 145)]])

    # @sprites[:cost] = BitmapSprite.new(770, 1500)
    # setSystemFont(@sprites[:cost].bitmap)
    # @sprites[:cost].y = @curHeight + @sprites[:cost].bitmap.text_size("X").height + SPACING
    # @sprites[:cost].z = 10
    # text = mTooltipData[:mLocKeys][:keyCost]
    # text ||= "#{mana[0]} Mana"
    # drawTextPositions(@sprites[:cost].bitmap, [[text, 1500 - SPACING, 0, :right, TEXTCOLOR]])

    @sprites[:div1] = BitmapSprite.new(@sprites[:bg].width - (SPACING * 2), 2)
    @sprites[:div1].bitmap.fill_rect(@sprites[:div1].bitmap.rect, Color.new(70, 65, 35))
    @sprites[:div1].x = SPACING
    @sprites[:div1].y = @sprites[:icon].y + @sprites[:icon].height + SPACING
    @sprites[:div1].z = 10

    @sprites[:name]&.dispose
    @sprites[:name] = BitmapSprite.new(@sprites[:bg].width, @sprites[:bg].height)
    @sprites[:name].x = @sprites[:icon].x + @sprites[:icon].width + SPACING
    @sprites[:name].y = @curHeight
    @sprites[:name].z = 100
    setSystemFont(@sprites[:name].bitmap)
    @sprites[:name].bitmap.font.size = 26
    drawFormattedTextEx(@sprites[:name].bitmap, 0, 0, @sprites[:name].bitmap.width, @augment.name, BOLDCOLOR, BOLDCOLOR)

    if @augment.quest
      @curHeight += @sprites[:name].bitmap.text_size("X").height + (SPACING / 2)
      @sprites[:level]&.dispose
      @sprites[:level] = BitmapSprite.new(@sprites[:bg].width, @sprites[:bg].height)
      @sprites[:level].x = @sprites[:icon].x + @sprites[:icon].width + SPACING
      @sprites[:level].y = @curHeight
      @sprites[:level].z = 100
      setSystemFont(@sprites[:level].bitmap)
      @sprites[:level].bitmap.font.size = 26
      drawFormattedTextEx(@sprites[:level].bitmap, 0, 0, @sprites[:level].bitmap.width, "<c=F0C200>Level 0</c>", BOLDCOLOR, BOLDCOLOR)
    end

    @sprites[:tooltip]&.dispose
    @sprites[:tooltip] = BitmapSprite.new(@sprites[:bg].width, @sprites[:bg].height)
    @sprites[:tooltip].y = @sprites[:div1].y + @sprites[:div1].bitmap.height + SPACING
    @sprites[:tooltip].z = 100
    setSystemFont(@sprites[:tooltip].bitmap)
    chars = getFormattedText(@sprites[:tooltip].bitmap, SPACING, 0, @sprites[:tooltip].bitmap.width - (2 * SPACING), @sprites[:bg].height, "<c=#{colorToRgb16(TEXTCOLOR)}>" + @augment.tooltip)
    drawFormattedChars(@sprites[:tooltip].bitmap, chars)
    @curHeight = chars[-1][2] + chars[-1][4] + SPACING + @sprites[:tooltip].y

    # @sprites[:div2] = BitmapSprite.new(@sprites[:bg].width - (SPACING * 2), 2)
    # @sprites[:div2].bitmap.fill_rect(@sprites[:div2].bitmap.rect, Color.new(70, 65, 35))
    # @sprites[:div2].x = SPACING
    # @sprites[:div2].y = @curHeight
    # @sprites[:div2].z = 10

    # @curHeight += SPACING

    # @sprites[:tooltipExt] = BitmapSprite.new(770, 1500)
    # @sprites[:tooltipExt].z = 10
    # setSystemFont(@sprites[:tooltipExt].bitmap)
    # chars = getFormattedText(@sprites[:tooltipExt].bitmap, SPACING, @curHeight, @sprites[:tooltipExt].bitmap.width - SPACING, @sprites[:bg].height, mTooltipData[:mLocKeys][:keyTooltipExtendedBelowLine])
    # drawFormattedChars(@sprites[:tooltipExt].bitmap, chars)
    # @curHeight = chars[-1][2] + chars[-1][4] + SPACING + @sprites[:tooltipExt].y

    # levels = ext[:levelCount]
    # textpos = []
    # ext[:Elements]&.each { |e|
    #   type = e[:type]
    #   name = e.fetch(:nameOverride, type)

    #   values = []
    #   case type
    #     when "Cooldown"
    #       values = cooldown[1..levels].map { |v| v == v.round ? v.to_i : v.round(2) }
    #     when "Cost"
    #       values = mana[...-1].map { |v| v == v.round ? v.to_i : v.round(2) }
    #     when "MarkRatio", "BaseMoveSpeed", "ExecutionThreshold"
    #       values = value(type)[1..levels].map { |v|
    #         ret = v * 100
    #         ret = ret == ret.round ? ret.to_i : ret.round(2)
    #         ret = ret == ret.round ? ret.to_i : ret.round(2)
    #       }.map { |v| "#{v}%" }
    #     else
    #       values = value(type)[1..levels].map { |v| v == v.round ? v.to_i : v.round(2) }
    #   end
    #   textpos.push([name, SPACING, @curHeight, :left, TEXTCOLOR])
    #   textpos.push(["[ #{values.join(" / ")} ]", @sprites[:tooltipExt].bitmap.width - SPACING, @curHeight, :right, BOLDCOLOR])

    #   @curHeight += @sprites[:tooltipExt].bitmap.text_size("X").height
    # }
    # drawTextPositions(@sprites[:tooltipExt].bitmap, textpos)


    @sprites[:bg].height = @curHeight + SPACING
  end

  def x
    return @sprites[:bg].x
  end
  def y
    return @sprites[:bg].y
  end
  def x=(v)
    offset = @sprites[:bg].x - v
    @sprites.each { |_, s| s.x -= offset }
  end
  def y=(v)
    offset = @sprites[:bg].y - v
    @sprites.each { |_, s| s.y -= offset }
  end
  def width
    return @sprites[:bg].width
  end
  def height
    return @sprites[:bg].height
  end

  def visible=(value)
    @sprites.each { |_, s| s.visible = value == true }
  end

end
