class MenuTab < UIElement
  attr_accessor :text
  attr_accessor :selected

  Y_OFFSET = 30

  def initialize(text, x, y, viewport = nil)
    @sprites = {}
    super(x, y, viewport)
    @selected = false
    @sprites[:contents] = Sprite.new(viewport)
    @sprites[:selHighlight] = IconSprite.new(0, 0, viewport)
    @sprites[:selHighlight].setBitmap("Graphics/UI/nav-highlight.png")
    @sprites[:selHighlight].opacity = 0
    @sprites[:gradient] = Sprite.new(viewport)
    @sprites[:gradient].opacity = 0
    @contents = Bitmap.new(1, 1)
    self.text = ""
    setSystemFont(@contents)
    @contents.font.name = "Beaufort for LOL"
    @contents.font.size = 28
    self.text = text
    resizeToFit()
    self.x = x
    self.y = y
  end

  def resizeToFit(maxwidth = Graphics.width) # maxwidth is maximum acceptable window width
    dims = [0, 0]
    getLineBrokenChunks(@contents, @text, maxwidth, dims, true)
    self.width = dims[0]
    self.height = dims[1] + Y_OFFSET
    @resize = true
    self.refresh
  end

  def text=(text)
    @contents.clear unless @contents.disposed?
    @text = "<ac>#{text}</ac>" unless text.include?("<ac>")
    #colorBmp.gradient_fill_rect(colorBmp.rect, color1, color2, true) # true = horizontal
    color = @selected ? HIGHLIGHT : TEXTCOLOR
    drawFormattedTextEx(@contents, 0, Y_OFFSET / 2, @width, @text, color, color)
    self.refresh(false)
  end

  def x=(value)
    super
    @sprites.each { |_, s| s&.x = value }
  end

  def y=(value)
    super
    @sprites.each { |_, s| s&.y = value }
  end

  def width=(value)
    @width = value
    self.refresh
  end

  def height=(value)
    @height = value
    self.refresh
  end

  def refresh(resize = true)
    @contents = doEnsureBitmap(@contents, self.width, self.height)
    @sprites[:contents].bitmap = @contents
    @highlightScaleX = (self.width.to_f / @sprites[:selHighlight].bitmap.width)
    @sprites[:selHighlight].zoom_x = @highlightScaleX
    @highlightScaleY = (self.height.to_f / @sprites[:selHighlight].bitmap.height)
    @sprites[:selHighlight].zoom_y = @highlightScaleY
    @sprites[:gradient].bitmap = doEnsureBitmap(Bitmap.new(1, 1), self.width, self.height)
    @sprites[:gradient].bitmap.gradient_fill_rect(Rect.new(0, 0, self.width, self.height), Color.new(0, 0, 0, 0), Color.new(205, 190, 145, 100), true)
    @sprites[:gradient].opacity = 255 if @selected && @sprites[:gradient].opacity == 0
    if resize
      resize = false
      self.text = @text
    end
  end

  def dispose
    super
    disposeSpriteHash(@sprites)
  end

  def update
    super

    oldselect = @selected
    @hover = self.mouseOver?
    if @hover
      @sprites[:gradient].opacity += 75
      @sprites[:selHighlight].opacity += 75
      x = Mouse::getMousePos(true)[0] - self.x
      @sprites[:selHighlight].src_rect.x = @sprites[:selHighlight].bitmap.width / 2 - (x / @highlightScaleX)

      @selected = true if Input.triggerex?(Input::LeftMouseKey) #&& self.enabled
    else
      @sprites[:selHighlight].opacity -= 125
      @sprites[:gradient].opacity -= 20 unless @selected
    end

    refresh if @selected != oldselect

    updateSpriteHash(@sprites)
  end
end
