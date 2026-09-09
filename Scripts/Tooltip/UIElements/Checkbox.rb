class Checkbox < UIElement
  attr_accessor :value
  def initialize(x, y, viewport = nil)
    super(x, y, viewport)
    @width = 84
    @height = 84
    @fill = @height * 2
    @value = false
    self.setBitmap("Graphics/UI/checkbox.png")
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
