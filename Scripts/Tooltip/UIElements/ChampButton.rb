class ChampButton < UIElement
  SPACING = 8
  SEL_OFFSET = 6
  attr_accessor :width, :height, :champ, :selected, :hover
  def initialize(champ, x, y, viewport)
    super(x, y, viewport)
    @width = 72
    @height = 72
    @selected = false
    @champ = champ
    @sprites = {}
    @sprites[:champ] = Image.new("Graphics/Champions/" + champ.icon, self.x + SPACING / 2, self.y + SPACING / 2, self.viewport)
    @sprites[:champ].scale = 0.5
    @sprites[:hover] = Image.new("Graphics/UI/champion_select", self.x, self.y, self.viewport)
    @sprites[:hover].visible = false
    @sprites[:sel] = AnimatedImage.new("Graphics/UI/champ_sel", 84, 40, nil, self.x - SEL_OFFSET, self.y - SEL_OFFSET, self.viewport)
    @sprites[:sel].visible = false
  end

  def update
    super

    oldselect = @selected
    @hover = self.mouseOver?
    clicked = false
    if @hover
      if Input.triggerex?(Input::LeftMouseKey)
        @selected = true
        clicked = true
      end
    end
    @sprites[:hover].visible = @hover || @selected
    @sprites[:sel].visible = @selected
    @sprites[:sel].resetFrame if clicked

    updateSpriteHash(@sprites)

    return oldselect != @selected
  end

  def x=(value)
    super
    @sprites&.each { |k, v|
      v.x = value
      v.x -= SEL_OFFSET if k == :sel
      v.x += SPACING / 2 if k == :champ
    }
  end

  def y=(value)
    super
    @sprites&.each { |k, v|
      v.y = value
      v.y -= SEL_OFFSET if k == :sel
      v.y += SPACING / 2 if k == :champ
    }
  end

  def resetFrame(value = 0)
    @sprites[:sel].resetFrame(value)
  end

  def frame
    @sprites[:sel].frameCount
  end

  def dispose
    super
    @sprites.each { |_, v| v&.dispose }
  end

  def visible=(value)
    @visible = value
    @selected = false if !value
    @sprites.each { |k, v|
      v.visible = value if k == :champ || !value
    }
  end
end
