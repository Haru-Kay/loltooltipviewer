class AnimatedImage < Image
  attr_accessor :frameCount
  def initialize(path, cellSize, frameLength, frames = nil, x = 0, y = 0, viewport = nil, cycle: false)
    super(path, x, y, viewport)
    cellSize = Array.new(2, cellSize) if cellSize.is_a?(Numeric)
    @playing = false
    @frameLength = frameLength
    @cellSize = cellSize
    @frame = 0
    @frameCount = 0
    @frameLength ||= 1
    self.src_rect = Rect.new(0, 0, *@cellSize)
    @maxX = self.bitmap.width
    @maxY = self.bitmap.height
    @totalFrames = (@maxX / @cellSize[0]) * (@maxY / @cellSize[1])
    @cycle = cycle
    @frameDiff = 1
  end

  def visible=(value)
    super
    @playing = value
  end

  def update
    super
    @frame += 1
    @frame %= (40 / @frameLength)
    self.advanceFrame if @playing && @frame == 0
  end

  def resetFrame(value = 0)
    @frameCount = value
  end

  def advanceFrame
    @frameCount += @frameDiff
    if @frameCount >= @totalFrames
      @frameCount = @cycle ? @frameCount - 1 : 0
      @frameDiff = @cycle ? -1 : 1
    end
    if @frameCount < 0
      @frameCount = @cycle ? 1 : @totalFrames - 1
      @frameDiff = @cycle ? 1 : -1
    end
    x = @frameCount * @cellSize[0]
    y = 0
    while x >= @maxX
      x -= @maxX
      y += @cellSize[1]
    end
    self.src_rect = Rect.new(x, y, *@cellSize)
  end
end
