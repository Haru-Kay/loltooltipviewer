class ChampionSelector < ScrollableContainer
  SPACING = 8
  CANVAS = 64
  SEARCH_HEIGHT = 32

  attr_accessor :selected

  def initialize(x, y, width, height)
    width -= width % (CANVAS + SPACING)
    super(x, y, width, height)

    @searchBar = SearchBar.new(0, 0, width, SEARCH_HEIGHT + SPACING / 2, self.viewport)
    @curSearch = @searchBar.text

    drawIcons
    @selected = nil
  end

  def mouseOver?
    mousepos = Mouse::getMousePos(true)

    return false if !mousepos
    return mousepos[0].between?(self.x, self.x + self.width) && mousepos[1].between?(self.y + SEARCH_HEIGHT + SPACING / 2, self.y + self.height)
  end

  def drawIcons(ableProc = proc { |champ| true })
    frame = 0
    @icons&.each_value { |v| v&.dispose; frame = v.frame if v.selected }
    @icons = {}
    x = 0
    y = @searchBar.height
    $cache.champions.each { |champ, data|
      next unless ableProc&.call(champ)

      button = ChampButton.new(data, x, y, self.viewport)
      x += button.width
      if x >= self.width
        y += button.height
        x = 0
      end
      if champ == @selected
        button.selected = true
        button.resetFrame(frame)
      end
      @icons[champ] = button
    }

    maxDist = y + (SPACING / 2 + CANVAS)
    origin = getFirstEntryY()
    self.scrollBounds = [origin, origin - maxDist + self.height]
  end

  def getFirstEntryY
    return @icons.values[0]&.y || super
  end

  def getScrollableContents
    return @icons
  end

  def update
    oldselected = @selected
    @searchBar.update
    updateScroll(self.mouse, self.scroll) if self.mouseOver?

    if @searchBar.text != @curSearch
      @curSearch = @searchBar.text
      drawIcons(proc { |champ| champ.downcase.include?(@curSearch) })
    end

    @icons.each_value { |i|
      if i.update
        self.select(i.champ)
      end
    }
  end

  def select(champ)
    return if @selected == champ.name
    @selected = champ.name
    @icons.each_value { |i| i.selected = false unless i.champ.name == champ.name }
  end

  def visible=(value)
    super
    @searchBar.visible = value
    @icons.each { |k, v| v.visible = value }
  end
end
