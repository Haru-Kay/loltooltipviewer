class TooltipBase < UIElement
  WIDTH = 835
  HEIGHT = 1500
  SPACING = 12

  BOLDCOLOR = Color.new(230, 220, 200)
  TEXTCOLOR2 = Color.new(160, 155, 140)
  UIColor = Color.new(70, 65, 35)
  SEARCHCOLOR = Color.new(80, 230, 190, 100)
  def initialize(x, y, width, height, viewport = nil)
    @viewport = viewport
    @sprites = {}
    @sprites[:bg] = SpriteWindow_Base.new(x, y, width, height, @viewport)
    @sprites[:bg].z = 1
    createOverlay(x, y, width, height)
    super(x, y, viewport)

    @width = width
    @height = height


    @curHeight = SPACING
  end

  def createOverlay(x = self.x, y = self.y, width = self.width, height = self.height, type: :overlay)
    @sprites[type] = BitmapSprite.new(width - SPACING, height, @viewport)
    @sprites[type].x = x
    @sprites[type].y = y
    @sprites[type].z = type == :overlay ? 3 : 2
    setSystemFont(@sprites[type].bitmap)
  end

  def createIcon(path = "Graphics/Icons/default")
    return if path.nil?
    @icon = true
    @sprites[:icon] = TooltipIcon.new(@viewport)
    @sprites[:icon].setBitmap(path)
    @sprites[:icon].scale = 64.0 / @sprites[:icon].bitmap.width
    @sprites[:icon].x = self.x + SPACING
    @sprites[:icon].y = @curHeight + self.y
    @sprites[:icon].z = 10
  end

  def createTitle(type: :title)
    @title = true
    @sprites[type] = BitmapSprite.new(@width, @height, @viewport)
    x = @sprites[:icon] ? @sprites[:icon].x + @sprites[:icon].width + SPACING : self.x + SPACING
    @sprites[type].x = x
    @sprites[type].y = @curHeight + self.y
    @sprites[type].z = 11
    setTitleFont(@sprites[type].bitmap)
  end

  def drawTitle(text = "", highlight = nil, type: :title)
    @titleText = text
    #drawFormattedTextEx(@sprites[type].bitmap, 0, 0, @width, @titleText, BOLDCOLOR, BOLDCOLOR)
    textsize = @sprites[type].bitmap.text_size("X").width
    chars = getFormattedText(@sprites[type].bitmap, 0, 0, @width, @height, "<c=#{colorToRgb16(BOLDCOLOR)}>" + @titleText + "</c>")
    if highlight
      highlightTextPos(@sprites[type].bitmap, chars, highlight)
    else
      drawFormattedChars(@sprites[type].bitmap, chars)
    end
  end

  def drawBody(text = "", highlight = nil, type: :overlay)
    @bodyText = text
    @body = true
    textsize = @sprites[type].bitmap.text_size("X").width
    chars = getFormattedText(@sprites[type].bitmap, SPACING, @curHeight, @width - SPACING - textsize,
                              @height, "<c=#{colorToRgb16(TEXTCOLOR2)}>" + @bodyText + "</c>")
    if highlight
      highlightTextPos(@sprites[type].bitmap, chars, highlight)
    else
      drawFormattedChars(@sprites[type].bitmap, chars)
    end

    @curHeight = chars[-1][2] + chars[-1][4] + SPACING
    fitToHeight
  end

  def createIconLine(highlight = nil, type: :overlay)
    x = SPACING
    y = @curHeight + @sprites[:icon].height + SPACING
    width = @sprites[type].bitmap.width - SPACING
    height = 2
    @sprites[type].bitmap.fill_rect(x, y, width, height, UIColor) unless highlight
    @curHeight += y + height
  end

  def fitToHeight
    @height = @curHeight
    @sprites[:bg].height = @height
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

  def highlight(text)
    @curHeight = SPACING
    #return if !@sprites[:highlight] && text.length < 3
    text = nil if text == ""

    @sprites[:highlight].bitmap.clear if @sprites[:highlight]
    @sprites[:titlehighlight].bitmap.clear if @sprites[:titlehighlight]
    return if text.nil?

    if @title
      createTitle(type: :titlehighlight) if !@sprites[:titlehighlight]
      drawTitle(@titleText, text, type: :titlehighlight)
    end
    createOverlay(type: :highlight) if !@sprites[:highlight]
    createIconLine(text, type: :highlight) if @icon
    drawBody(@bodyText, text, type: :highlight) if @body
  end

  class TooltipIcon < IconSprite
    def width
      return (self.bitmap.width * self.zoom_x).to_i
    end

    def height
      return (self.bitmap.height * self.zoom_y).to_i
    end

    def scale=(value)
      @scale = value
      self.zoom_x = value
      self.zoom_y = value
    end
  end
end

class AugmentTooltip < TooltipBase
  attr_accessor :augment
  def initialize(augment, x, y, viewport = nil)
    super(x, y, TooltipBase::WIDTH, TooltipBase::HEIGHT, viewport)
    @augment = AugmentCache.augments[augment]
    iconpath = @augment.icon.downcase[...-4].split("/")[-1]
    createIcon("Graphics/Images/#{iconpath}.png")
    createTitle()
    drawTitle(@augment.name)
    createIconLine()
    drawBody(@augment.tooltip)
  end

  def fitToHeight
    super
  end
end
