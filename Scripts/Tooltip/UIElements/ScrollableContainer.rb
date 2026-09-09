class ScrollableContainer
  attr_accessor :visible, :x, :y, :viewport, :scrollBounds, :mouse, :scroll
  def initialize(x, y, width, height)
    @mouse = [0, 0]
    @scroll = 0
    @x = x
    @y = y
    @viewport = Viewport.new(x, y, width, height)
    @visible = true
    @scrollBounds = [0, height]
  end

  def width; @viewport.rect.width; end
  def height; @viewport.rect.height; end

  def mouseOver?
    mousepos = Mouse::getMousePos(true)

    return false if !mousepos
    return mousepos[0].between?(self.x, self.x + self.width) && mousepos[1].between?(self.y, self.y + self.height)
  end

  def getFirstEntryY; 0; end
  def getScrollableContents; end

  def updateScroll(oldmouse, oldscroll)
    mouse = Mouse::getMousePos(true)
    scroll = Input.scroll_v

    curY = self.getFirstEntryY
    diff = 0
    if Input.pressex?(Input::LeftMouseKey)
      realdiff = mouse[1] - oldmouse[1]
      if curY + realdiff > @scrollBounds[0]
        realdiff = @scrollBounds[0] - curY
      end
      diff = realdiff
    end

    if scroll != oldscroll
      diff = 72 * scroll
    end

    if diff != 0
      if curY + diff > @scrollBounds[0]
        diff = @scrollBounds[0] - curY
      end
      if curY + diff < @scrollBounds[1]
        diff = @scrollBounds[1] - curY
      end

      self.getScrollableContents&.each { |k, v| v.y += diff }
    end

    @mouse = mouse
    @scroll = scroll
  end
end
