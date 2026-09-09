class AugmentViewerEntry < UIElement
  OPACITY = 150
  attr_accessor :height, :width, :rarity, :name, :weight, :percent
  def initialize(augment, x, y, viewport = nil)
    super(x, y, viewport)
    @height = 48
    @width = self.viewport.rect.width
    @sprites = {}
    icon = $cache.augments[augment].icon
    @name = $cache.augments[augment].name
    @rarity = ["Silver", "Gold", "Prismatic"].index($cache.augments[augment].rarity)

    self.bitmap = Bitmap.new(@width, @height)
    self.bitmap.fill_rect(0, 0, @width, @height, Color.new(30, 35, 40))
    self.opacity = 0


    @sprites[:icon] = Image.new(icon, getTableColumnDims[0], y, self.viewport)
    @sprites[:icon].scale = @height.to_f / @sprites[:icon].bitmap.width
    @sprites[:name] = Label.new(@name, getTableColumnDims[1], 0, self.viewport)
    @sprites[:name].y = y + (@sprites[:icon].height / 2) - (@sprites[:name].height / 2) + 4

    @sprites[:weight] = Label.new("", getTableColumnDims[2], @sprites[:name].y, self.viewport)
    @sprites[:percent] = Label.new("", getTableColumnDims[3], @sprites[:name].y, self.viewport)

    @sprites[:disable] = Checkbox.new(getTableColumnDims[4], 0, self.viewport)
    @sprites[:disable].scale = 1.0 / 3
    @sprites[:disable].y = self.y + (self.height / 2) - (@sprites[:disable].height / 2)

    @sprites[:line] = BitmapSprite.new(self.viewport.rect.width, 1, self.viewport)
    @sprites[:line].bitmap.fill_rect(@sprites[:line].bitmap.rect, Color.new(30, 35, 40))
    @sprites[:line].y = self.y + (@sprites[:icon].height)

    # @sprites[:bg] = BitmapSprite.new(self.viewport.rect.width, self.y + (@sprites[:icon].height) - 1, self.viewport)
    # @sprites[:bg].x = self.x
    # @sprites[:bg].y = self.y
    # @sprites[:bg].bitmap.fill_rect(@sprites[:bg].bitmap.rect, Color.new(30, 35, 40))
    # @sprites[:bg].opacity = 0
    # @sprites[:bg].z = -1
    @hover = false
  end

  def disabled?
    return @sprites[:disable].value
  end

  def setWeights(weight, total)
    @weight = weight
    @percent = (weight.to_f / total) * 100
    @sprites[:weight].text = @weight.to_s
    @sprites[:percent].text = sprintf("%0.2f%%", @percent)
  end

  def update
    hover = @hover
    super
    checked = self.disabled?
    @sprites&.each { |k, v| v.update }

    @hover = self.mouseOver?
    self.opacity = @hover ? OPACITY : 0 if hover != @hover

    return checked != disabled?
  end

  def dispose
    @sprites&.each_value { |v| v&.dispose }
  end

  def x=(value)
    super
    @sprites&.each { |k, v|
      v.x = value
    }
  end

  def y=(value)
    super
    return if !@sprites
    @sprites[:icon].y = value
    @sprites[:name].y = value + (@sprites[:icon].height / 2) - (@sprites[:name].height / 2) + 4
    @sprites[:line].y = value + (@sprites[:icon].height)
    @sprites[:disable].y = value + (self.height / 2) - (@sprites[:disable].height / 2)
    @sprites[:weight].y = @sprites[:name].y
    @sprites[:percent].y = @sprites[:name].y
  end
end
