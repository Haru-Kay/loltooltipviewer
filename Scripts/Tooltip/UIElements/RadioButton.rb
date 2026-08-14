class RadioButton < UIElement

  attr_accessor :value
  attr_accessor :hover
  attr_accessor :scale

  def initialize(x, y, viewport = nil)
    super(x, y, viewport)
    @width = 80
    @height = 80
    @fill = @height * 4
    @value = false
    @clicked = false
    self.setBitmap("Graphics/UI/btn_icon.png")
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
      @clicked = true
    end

    if Input.pressex?(Input::LeftMouseKey) && @clicked
      yPos = @height * 2
    else
      @clicked = false
    end

    yPos += @fill * @value.to_i if @value

    self.src_rect.y = yPos
  end
end
