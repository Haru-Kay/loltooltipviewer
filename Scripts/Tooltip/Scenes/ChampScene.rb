class ChampScene
  def initialize(x, y)
    @viewport = Viewport.new(x, y, Graphics.width, Graphics.height - y)
    @width = @viewport.rect.width
    @height = @viewport.rect.height
    @elements = {}

    @elements[:champions] = ChampionSelector.new(x, y, Graphics.width / 3, @height)

    #@elements[:bg].bitmap.fill_rect(0, @elements[:btn1].height - 1, Graphics.width, 1, Color.new(60, 60, 65))
    @elements[:div] = BitmapSprite.new(1, @height + 4)
    @elements[:div].x = @elements[:champions].width + 2
    @elements[:div].y = @elements[:champions].y - 4
    @elements[:div].bitmap.fill_rect(0, 0, 1, @height + 4, Color.new(70, 55, 20))

    @elements[:augmentViewer] = ChampionAugmentViewer.new(@elements[:div].x + 2, y, Graphics.width - @elements[:champions].width - 2, @height)

    @visible = true
  end

  def update
    @elements[:champions].update
    @selected = @elements[:champions].selected

    @elements[:augmentViewer].update(@selected)

    @elements[:div].update
  end

  def visible=(value)
    @visible = value
    @elements.each { | k, v| v.visible = value }
  end
end

=begin

    sums = @augmentPool.values.map { |v| v.values.map { |w| w[:weight] }.sum }
    @augmentPool.each { |rarity, augs|
      augs.each { |aug, data|
        data[:percent] = (data[:weight].to_f / sums[rarity]).round(4)
      }
    }
    p @augmentPool
=end
