class Label < UIElement
  attr_accessor :text
  def initialize(text, x, y, viewport = nil)
    super(x, y, viewport)
    @text = text
    @color = TEXTCOLOR
    self.bitmap = Bitmap.new(1, 1)
    setSystemFont(self.bitmap)
    resizeToFit()
    drawText()
  end

  def drawText
    self.bitmap = doEnsureBitmap(self.bitmap, self.width, self.height)
    chars = getFormattedText(self.bitmap, 0, 0, self.width, self.height, "<c=#{colorToRgb16(@color)}>" + @text + "</c>")
    drawFormattedChars(self.bitmap, chars)
  end

  def font=(value, textsize = nil)
    self.bitmap.font.name = value
    self.changeTextSize(textsize, draw: false) if textsize
    resizeToFit()
    drawText()
  end

  def changeTextSize(size, draw: true)
    self.bitmap.font.size = size
    if draw
      resizeToFit()
      drawText()
    end
  end

  def text=(text)
    self.bitmap.clear
    @text = text
    resizeToFit()
    drawText()
  end

  def color=(color)
    self.bitmap.clear
    @color = color
    drawText()
  end

  def resizeToFit(maxwidth = Graphics.height)
    dims = [0, 0]
    chars = getFormattedTextForDims(self.bitmap, 0, 0, maxwidth, -1, text, 32, true)
    for ch in chars
      dims[0] = [dims[0], ch[1] + ch[3]].max
      dims[1] = [dims[1], ch[2] + ch[4]].max
    end
    self.src_rect.set(0, 0, *dims)
    @width = dims[0]
    @height = dims[1]
  end
end
