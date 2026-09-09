class BaseScene
  def initialize
    @elements = {}
    @elements[:bg] = IconSprite.new(1, 1)
    @elements[:bg].setBitmap("Graphics/UI/background")

    @elements[:btn1] = MenuTab.new("Mayhem", 0, 0)
    @elements[:btn1].width = 120
    # @elements[:btn2] = MenuTab.new("Champions", @elements[:btn1].width + @elements[:btn1].x, 0)
    # @elements[:btn2].width = 120
    # @elements[:btn2].selected = true
    # @elements[:btn2].refresh(true)
    # @elements[:btn2].enabled = false
    # @elements[:btn3] = MenuTab.new("Arena", @elements[:btn2].width + @elements[:btn2].x, 0)
    # @elements[:btn3].width = 120
    # @elements[:btn3].enabled = false

    @elements[:bg].bitmap.fill_rect(0, @elements[:btn1].height - 1, Graphics.width, 1, Color.new(70, 55, 20))

    @tabs = [@elements[:btn1]]#, @elements[:btn2]]#, @elements[:btn3]]
    @tabsel = 0
    # @tabs.each_with_index { |t, i|
    #   if t.selected
    #     @tabsel = i
    #     break
    #   end
    # }
    # @subscenes = Array.new(@tabs.length, nil)
    # threads = [
    #   Thread.new { @subscenes[0] = MayhemScene.new },
    #   Thread.new { @subscenes[1] = ChampScene.new }
    # ]
    @subscene = ChampScene.new(0, @elements[:btn1].height + 4)
  end

  def main
    mouse = [0, 0]
    scroll = 0
    while true
      Graphics.update
      Input.update
      update()

    end
  end

  def update
    oldstate = @tabs.map { |tab| tab.selected }
    @elements.each { |_, e| e.update }
    state = @tabs.map { |tab| tab.selected }
    if state != oldstate
      state.each_with_index { |value, i|
        if value && value != oldstate[i]
          @tabsel = i
          @tabs.each_with_index { |tab, j|
            tab.selected = false unless j == i
            tab.refresh(true)
          }
          break
        end
      }
    end

    @subscene.update
  end

  def updateMouse(oldmouse, oldscroll)
    mouse = Mouse::getMousePos(true)
    scroll = Input.scroll_v

    return mouse, scroll
  end
end
