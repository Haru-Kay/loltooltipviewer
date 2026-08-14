class UIElement < SpriteWrapper
  TEXTCOLOR = Color.new(205, 190, 145)
  HIGHLIGHT = Color.new(240, 230, 210)
  SHADOWCOLOR = Color.new(160, 155, 140)

  attr_accessor :hover
  attr_accessor :enabled
  def initialize(x, y, viewport = nil)
    super(viewport)
    self.scale = 1
    self.x = x
    self.y = y
    @width = 1
    @height = 1
    @scale = 1
    @enabled = true
    @hover = self.mouseOver?
  end

  def scale=(value)
    self.zoom_x = value
    self.zoom_y = value
  end

  def width
    return @width * self.zoom_x
  end

  def height
    return @height * self.zoom_y
  end

  def owidth
    return @width
  end

  def oheight
    return @height
  end

  def mouseOver?
    mousepos = Mouse::getMousePos(true)

    return false if !mousepos
    return mousepos[0].between?(self.x, self.x + self.width) && mousepos[1].between?(self.y, self.y + self.height)
  end

  def dispose
    clearBitmaps()
    super
  end

  def update
    super
    if @_iconbitmap
      @_iconbitmap.update
      if self.bitmap != @_iconbitmap.bitmap
        oldrc = self.src_rect
        self.bitmap = @_iconbitmap.bitmap
        self.src_rect = oldrc
      end
    end
  end

  def setBitmap(file, hue = 0)
    oldrc = self.src_rect
    clearBitmaps()
    return if file == nil

    if file != ""
      @_iconbitmap = AnimatedBitmap.new(file, hue)
      # for compatibility
      self.bitmap = @_iconbitmap ? @_iconbitmap.bitmap : nil
      self.src_rect = oldrc
    else
      @_iconbitmap = nil
    end
  end

  def clearBitmaps
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = nil
    self.bitmap = nil if !self.disposed?
  end
end
