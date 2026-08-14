class Button < UIElement
  attr_accessor :state
  attr_accessor :action
  def initialize(graphic, action, viewport = nil)
    super(0, 0, viewport)
    graphic = "Graphics/UI/#{graphic}" if !graphic.include?("/")
    graphic += ".png" if !graphic.end_with?(".png")
    self.setBitmap(graphic)
    @width = self.bitmap.width
    @height = self.bitmap.height
    self.src_rect = Rect.new(0, 0, @width, @height)
    @action = action
  end

  def update
    super

    if self.mouseOver? && Input.triggerex?(Input::LeftMouseKey)
      @action.call
    end
  end
end
