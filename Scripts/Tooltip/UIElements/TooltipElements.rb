class TooltipBase < UIElement
  WIDTH = 835
  HEIGHT = 1500
  SPACING = 12

  BOLDCOLOR = Color.new(230, 220, 200)
  TEXTCOLOR2 = Color.new(160, 155, 140)
  UIColor = Color.new(70, 65, 35)
  def initialize(x, y, width, height, viewport = nil)
    @viewport = viewport
    @sprites = {}
    @sprites[:bg] = SpriteWindow_Base.new(x, y, width, height, @viewport)
    @sprites[:bg].z = 1
    @sprites[:overlay] = BitmapSprite.new(width - SPACING, height, @viewport)
    @sprites[:overlay].x = x
    @sprites[:overlay].y = y
    @sprites[:overlay].z = 2
    super(x, y, viewport)

    @width = width
    @height = height
    setSystemFont(@sprites[:overlay].bitmap)


    @curHeight = SPACING
  end

  def createIcon(path = "Graphics/Icons/default")
    return if path.nil?
    @sprites[:icon] = TooltipIcon.new(@viewport)
    @sprites[:icon].setBitmap(path)
    @sprites[:icon].scale = 64.0 / @sprites[:icon].bitmap.width
    @sprites[:icon].x = self.x + SPACING
    @sprites[:icon].y = @curHeight + self.y
    @sprites[:icon].z = 10
  end

  def createTitle(text = "")
    @sprites[:title] = BitmapSprite.new(@width, @height, @viewport)
    x = @sprites[:icon] ? @sprites[:icon].x + @sprites[:icon].width + SPACING : self.x + SPACING
    @sprites[:title].x = x
    @sprites[:title].y = @curHeight + self.y
    @sprites[:title].z = 11
    setTitleFont(@sprites[:title])
    drawFormattedTextEx(@sprites[:title].bitmap, 0, 0, @width, text, BOLDCOLOR, BOLDCOLOR)
  end

  def drawBody(text = "")
    textsize = @sprites[:overlay].bitmap.text_size("X").width
    chars = getFormattedText(@sprites[:overlay].bitmap, SPACING, @curHeight, @width - SPACING - textsize, @height, "<c=#{colorToRgb16(TEXTCOLOR2)}>" + text + "</c>")
    drawFormattedChars(@sprites[:overlay].bitmap, chars)
    @curHeight = chars[-1][2] + chars[-1][4] + SPACING
    fitToHeight
  end

  def createIconLine
    x = SPACING
    y = @curHeight + @sprites[:icon].height + SPACING
    width = @sprites[:overlay].bitmap.width - SPACING
    height = 2
    @sprites[:overlay].bitmap.fill_rect(x, y, width, height, UIColor)
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
    createTitle(@augment.name)
    createIconLine()
    drawBody(@augment.tooltip)
  end

  def fitToHeight
    super
  end
end
