class BaseScene
  def initialize
    @elements = {}
    @elements[:bg] = IconSprite.new(1, 1)
    @elements[:bg].setBitmap("Graphics/UI/background")

    @elements[:btn1] = MenuTab.new("Mayhem", 0, 0)
    @elements[:btn1].width = 120
    @elements[:btn1].selected = true
    @elements[:btn1].refresh(true)
    # @elements[:btn2] = MenuTab.new("Classic-ish", @elements[:btn1].width + @elements[:btn1].x, 0)
    # @elements[:btn2].width = 120
    # @elements[:btn2].enabled = false
    # @elements[:btn3] = MenuTab.new("Arena", @elements[:btn2].width + @elements[:btn2].x, 0)
    # @elements[:btn3].width = 120
    # @elements[:btn3].enabled = false

    @elements[:bg].bitmap.fill_rect(0, @elements[:btn1].height - 1, Graphics.width, 1, Color.new(60, 60, 65))

    @tabs = [@elements[:btn1]]#, @elements[:btn2], @elements[:btn3]]
    @tabsel = 0
    @elements[:txtSearch] = SearchBar.new(0, @elements[:btn1].height - SearchBar::HEIGHT)
    @curSearch = @elements[:txtSearch].text

    @elements[:cbHighlight] = Checkbox.new(false, 0, 42)
    @elements[:lbHighlight] = Label.new("Highlight Search", 0, 42)
    @elements[:lbHighlight].x = @elements[:txtSearch].x - @elements[:lbHighlight].width - 6
    @elements[:cbHighlight].x = @elements[:lbHighlight].x - @elements[:cbHighlight].width - 6

    @augmentList = AugmentCache.keys.sort_by { |s| AugmentCache.augments[s].name }
    @augments = []
    @loaded = false
    @elements[:loading] = BitmapSprite.new(Graphics.width, Graphics.height - @elements[:btn1].height)
    @elements[:loading].y = @elements[:btn1].height
    @elements[:loading].z = 999
    setSystemFont(@elements[:loading].bitmap)
    @elements[:loading].bitmap.fill_rect(@elements[:loading].src_rect, Color.new(100, 100, 100, 100))
    drawFormattedTextEx(@elements[:loading].bitmap, 0, @elements[:loading].bitmap.height / 2, Graphics.width, "<ac><fs=60>Loading...", Color.new(205, 190, 145), Color.new(205, 190, 145))
    $loadtime = Time.now

    @augmentViewport = Viewport.new(4, @elements[:btn1].height + 4, Graphics.width, Graphics.height)
    @augmentViewport.z = 10
  end

  def shouldHighlight?
    return @elements[:cbHighlight].value
  end

  def main
    mouse = [0, 0]
    scroll = 0
    while true
      highlight = self.shouldHighlight?
      ensureAugments()
      Graphics.update
      Input.update
      update()

      if @loaded
        mouse, scroll = updateMouse(mouse, scroll)

        if self.shouldHighlight? != highlight
          updateAugments
        end
      end
    end
  end

  def update
    oldstate = @tabs.map { |tab| tab.selected }
    @elements.each { |_, e| e.update }
    state = @tabs.map { |tab| tab.selected }
    if state != oldstate
      # state.each_with_index { |value, i|
      #   if value && value != oldstate[i]
      #     @tabsel = i
      #     @tabs.each_with_index { |tab, j|
      #       tab.selected = false unless j == i
      #       tab.refresh(true)
      #     }
      #     break
      #   end
      # }
    end

    if @loaded && @elements[:txtSearch].text != @curSearch
      @augmentList = searchAugments(@elements[:txtSearch].text)
      updateAugments
    end
    #@augments.each { |a| a.update }
  end

  def searchAugments(text)
    @curSearch = text
    return AugmentCache.keys.sort_by { |s| AugmentCache.augments[s].name } if text == ""

    ret = AugmentCache.keys.filter { |s|
      AugmentCache.augments[s].name.downcase.include?(@curSearch) || toUnformattedText(AugmentCache.augments[s].tooltip).downcase.include?(@curSearch)
    }.sort_by { |s| AugmentCache.augments[s].name }

    return ret
  end

  def updateMouse(oldmouse, oldscroll)
    mouse = Mouse::getMousePos(true)
    scroll = Input.scroll_v

    if Input.pressex?(Input::LeftMouseKey)
      realdiff = mouse[1] - oldmouse[1]
      if @augments[0].y + realdiff > 0
        realdiff = 0 - @augments[0].y
      end
      @augments.each { |t| t.y += realdiff } if realdiff != 0
    end

    if scroll != oldscroll
      if @augments[0].y + (72 * scroll) <= 0
        @augments.each { |t| t.y += (72 * scroll) }
      end
    end

    return mouse, scroll
  end

  def ensureAugments
    return if @loaded
    begin
      25.times {
        break if @augments.length == @augmentList.length
        y = @augments.length > 0 ? @augments[-1].y + @augments[-1].height + 8 : 0
        @augments << AugmentTooltip.new(@augmentList[@augments.length], 0, y, @augmentViewport)
      }
      if @augments.length == @augmentList.length #|| true
        puts Time.now - $loadtime
        @loaded = true
        @elements[:loading].dispose
        @elements.delete(:loading)
      end
    rescue
      raise "broke at augment #{@augmentList[@augments.length]}"
    end
  end

  def updateAugments
    height = 0
    @augments.each_with_index { |tooltip, i|
      augment = tooltip.augment.apiName
      if @augmentList.include?(augment)
        tooltip.y = height
        height += tooltip.height + 8
        tooltip.visible = true
        tooltip.highlight(@curSearch, self.shouldHighlight?)
      else
        tooltip.visible = false
      end
    }
  end
end
