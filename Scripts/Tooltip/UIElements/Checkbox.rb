class Checkbox < UIElement
  attr_reader :value
  def initialize(value, x, y, viewport = nil)
    super(x, y, viewport)
    @value = value
    @width = 14
    @height = 14
    @fill = @height * 2
    @value = false
    self.setBitmap("Graphics/UI/checkbox-spritesheet.png")
    self.src_rect = Rect.new(0, 0, @width, @height)
  end

  def update
    super
    yPos = 0

    oldHover = @hover
    @hover = self.mouseOver?
    yPos = @height * @hover.to_i

    oldValue = @value
    if Input.triggerex?(Input::LeftMouseKey) && @hover
      @value = !@value
    end

    yPos += @fill * @value.to_i if @value

    self.src_rect.y = yPos
  end
end
