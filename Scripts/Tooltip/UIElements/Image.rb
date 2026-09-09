class Image < IconSprite
  def initialize(path, x = 0, y = 0, viewport = nil)
    super(x, y, viewport)
    self.setBitmap(path)
  end

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
