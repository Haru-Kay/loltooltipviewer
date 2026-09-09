class AugmentViewerTableHeader < UIElement
  OPACITY = 150
  attr_accessor :height, :width, :idx, :sortProc, :mode
  def initialize(idx, y, viewport = nil)
    super(getTableColumnDims[idx] - 5, y, viewport)
    self.x -= 3 if idx == 0
    @height = 48
    @idx = idx
    @width = (getTableColumnDims[idx + 1] || Graphics.width) - getTableColumnDims[idx] #- 15
    @sprites = {}


    @sprites[:label] = Label.new("<b>" + getTableColumnNames[idx] + "</b>", x + 10, y + 4, self.viewport)
    @height = @sprites[:label].height + 4

    self.bitmap = Bitmap.new(@width, @height)
    self.bitmap.fill_rect(0, 0, @width, @height, Color.new(45, 55, 60))
    self.opacity = 0

    @mode = 0
    @sortProc = nil
  end

  def update
    hover = @hover
    super
    @hover = self.mouseOver?
    self.opacity = @hover ? OPACITY : 0 if hover != @hover

    if @hover && Input.triggerex?(Input::LeftMouseKey) && @sortProc
      @mode += 1
      @mode %= 3
      @sprites[:label].text = "<b>" + getTableColumnNames[idx] + "</b>" + ["", " <icon=btnUp>", " <icon=btnDown>"][@mode]
      @sortProc.call(@mode)
    end
    self.opacity = OPACITY if @mode > 0

    @sprites[:label].update
  end

  def z=(value)
    super
    @sprites[:label].z = value
  end

  def mode=(value)
    @mode = value
    self.opacity = 0 if value == 0
    @sprites[:label].text = "<b>" + getTableColumnNames[idx] + "</b>" + ["", " <icon=btnUp>", " <icon=btnDown>"][@mode]
  end

end
