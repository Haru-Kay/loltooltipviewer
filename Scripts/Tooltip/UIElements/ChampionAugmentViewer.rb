class ChampionAugmentViewer
  SPACING = 8

  attr_accessor :visible
  def initialize(x, y, width, height)
    @x = x
    @y = y
    @viewport = Viewport.new(x, y, width, height)

    @sprites = {}
    @selected = nil
  end

  def update(selected)
    if selected != @selected&.name
      @selected = $cache.champions[selected]
      @sprites.each_value { |v| v&.dispose }
      @sprites = {}
      @sprites[:champ] = Image.new("Graphics/Champions/" + @selected.icon, 0, 0, @viewport)
      @sprites[:text] = Label.new(@selected.name, @sprites[:champ].width + SPACING, @sprites[:champ].y - 1, @viewport)
      @sprites[:text].changeTextSize(48)

      y = @sprites.values[-1].height - SPACING / 2 - 1
      @checkboxes = []
      for i in 0..2
        createCheckbox(i, y)
        y += @sprites.values[-2].height + SPACING / 2
      end

      @augments ||= AugmentViewerTable.new(@x, @y + @sprites[:champ].height + SPACING, @viewport.rect.width, @viewport.rect.height - y)
      @augments.setupTable(@selected, @checkboxes&.map { |c| @sprites[c].value })
      # @selected.augmentPool[0].sort_by { |k, v| v }.reverse.to_h.each { |a, v|
      #   augment = $cache.augments[a].name
      #   @sprites["#{a}_text"] = Label.new(augment + ": #{v}", 0, y, @viewport)
      #   y += @sprites["#{a}_text"].height + SPACING / 2
      # }
    end

    oldValues = @checkboxes&.map { |c| @sprites[c].value }
    @sprites.each { |k, v| v.update }

    curValues = @checkboxes&.map { |c| @sprites[c].value }
    if oldValues != curValues
      @augments.setupTable(@selected, @checkboxes&.map { |c| @sprites[c].value })
    end
    @augments&.update
  end

  def createCheckbox(rarity, y)
    i = "cbRarity#{rarity}"
    x = @sprites[:champ].width + SPACING
    @sprites[i] = Checkbox.new(x, y, @viewport)
    @sprites[i].scale = 1.0 / 3
    @sprites[i].value = true
    @checkboxes.push(i)

    text = ["Silver", "Gold", "Prismatic"][rarity]
    @sprites["cbRarity#{i}Label"] = Label.new(text, x + @sprites[i].width + SPACING, y + SPACING / 2, @viewport)
  end

  def visible=(value)
    @visible = value
    @sprites.each { |k, v| v.visible = value }
  end
end
