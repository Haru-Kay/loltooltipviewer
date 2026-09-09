class AugmentViewerTable < ScrollableContainer
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @augments = {}
    @sprites = {}
    @champ = nil
    #columns = [:icon, :name, :weight, :perc, :shouldDisable] #show tt on entry hover

    defaultSort = proc { |mode|
      ret = [0, 0, 0]
      ret[mode % 3] = 0
      ret[(mode + 1) % 3] = 100
      ret[(mode + 2) % 3] = 200
      @tableHeaders.each { |k, v| v.mode = 0 unless k == :rarity }
      sortAugments(mode, proc { |mode, a, b| next ret[a.rarity] <=> ret[b.rarity] })
    }

    @tableHeaders = {}
    @tableHeaders[:rarity] = AugmentViewerTableHeader.new(0, 0, self.viewport)
    @tableHeaders[:rarity].z = 20
    @tableHeaders[:rarity].sortProc = defaultSort
    @tableHeaders[:name] = AugmentViewerTableHeader.new(1, 0, self.viewport)
    @tableHeaders[:name].z = 20
    @tableHeaders[:name].sortProc = proc { |mode|
      @tableHeaders.each { |k, v| v.mode = 0 unless k == :name }
      mode == 0 ? defaultSort.call(mode) :
      sortAugments(mode, proc { |mode, a, b|
        l = a
        r = b
        if mode == 2
          l = b
          r = a
        end
        next l.name.downcase <=> r.name.downcase })
    }
    @tableHeaders[:weight] = AugmentViewerTableHeader.new(2, 0, self.viewport)
    @tableHeaders[:weight].z = 20
    @tableHeaders[:weight].sortProc = proc { |mode|
      @tableHeaders.each { |k, v| v.mode = 0 unless k == :weight }
      mode == 0 ? defaultSort.call(mode) :
      sortAugments(mode, proc { |mode, a, b|
        l = a
        r = b
        if mode == 2
          l = b
          r = a
        end
        next l.weight <=> r.weight })
    }
    @tableHeaders[:percent] = AugmentViewerTableHeader.new(3, 0, self.viewport)
    @tableHeaders[:percent].z = 20
    @tableHeaders[:percent].sortProc = proc { |mode|
      @tableHeaders.each { |k, v| v.mode = 0 unless k == :percent }
      mode == 0 ? defaultSort.call(mode) :
      sortAugments(mode, proc { |mode, a, b|
        l = a
        r = b
        if mode == 2
          l = b
          r = a
        end
        next l.percent <=> r.percent })
    }
    @tableHeaders[:disable] = AugmentViewerTableHeader.new(4, 0, self.viewport)
    @tableHeaders[:disable].z = 20
    @sprites[:bg] = BitmapSprite.new(self.viewport.rect.width, @tableHeaders.values[-1].height, self.viewport)
    @sprites[:bg].z = 10
    @sprites[:bg].bitmap.fill_rect(@sprites[:bg].bitmap.rect, Color.new(30, 35, 40))
  end

  def setupTable(champ, list = [true, true, true])
    return if !champ
    @champ = champ
    @tableHeaders.each { |k, v| v.mode = 0 }
    @augments&.each_value { |v| v&.dispose }
    @augments = {}
    y = @tableHeaders.values[0].height
    totals = @champ.augmentPool.values.map { |a| a.values.sum }
    @champ.augmentPool.each { |rarity, pool|
      next unless list[rarity]
      pool.each { |a, w|
        @augments[a] = AugmentViewerEntry.new(a, 0, y, self.viewport)
        @augments[a].setWeights(w, totals[rarity])
        y += @augments[a].height
      }
    }
    maxDist = y
    origin = getFirstEntryY()
    self.scrollBounds = [origin, origin - maxDist + self.height]
  end

  def sortAugments(mode, sortProc)
    y = @tableHeaders.values[0].height
    sortedAugs = @augments.values.sort { |a, b| sortProc.call(mode, a, b) }
    sortedAugs.each_with_index { |a, i|
      a.y = y
      y += a.height
    }
    #@augments.values.each_with_index { |a, i| a.y = ypos[i] }
  end

  def updateWeights
    modded = [{}, {}, {}]
    @champ.augmentPool.each { |rarity, pool|
      pool.each { |a, w|
        modded[rarity].store(a, @augments[a]&.disabled? ? 0 : w)
      }
    }
    totals = modded.map { |a| a.values.sum }
    @augments.each { |a, entry|
      rarity = ["Silver", "Gold", "Prismatic"].index($cache.augments[a].rarity)
      entry.setWeights(modded[rarity][a], totals[rarity])
    }
    @tableHeaders.each { |k, v| v.mode = 0 }
  end

  def getFirstEntryY
    return super if !@augments
    return @augments.values.map { |a| a.y }.min
  end

  def getScrollableContents
    return @augments
  end

  def x; @x; end
  def y; @y; end
  def width; @viewport.rect.width; end
  def height; @viewport.rect.height; end

  def update
    updateScroll(self.mouse, self.scroll) if self.mouseOver?
    @tableHeaders.each { |k, v| v.update }
    changed = false
    @augments.each { |k, v| changed = changed || v.update }
    self.updateWeights if changed
  end

  def visible=(value)
    @visible = value
    @searchBar.visible = value
    @augments.each { |k, v| v.visible = value }
    @tableHeaders.each { |k, v| v.visible = value }
  end

  def dispose
    @augments.each { |k, v| v&.dispose }
    @tableHeaders.each { |k, v| v&.dispose }
  end
end

def getTableColumnDims
  [
    8, 85, 525, 650, 830
  ]
end

def getTableColumnNames
  [
    "Tier", "Name", "Weight", "Appear Rate", "Hide Augment?"
  ]
end
