class SearchBar < UIElement
  attr_accessor :text
  attr_accessor :focus

  WIDTH = 255
  HEIGHT = 36
  OFFSET = 6

  def initialize(x, y, width, height, viewport = nil)
    #super(Graphics.width - WIDTH + x, y, viewport)
    super(x, y, viewport)
    @focus = false
    @sprites = {}
    #@width = WIDTH
    @width = width
    @height = height
    @sprites[:bg] = SpriteWindow_Base.new(self.x, self.y, width, height, viewport)
    @sprites[:bg].z = 1

    scale = 0.33
    @sprites[:icon] = IconSprite.new(self.x + OFFSET, self.y + OFFSET, viewport)
    @sprites[:icon].setBitmap("Graphics/UI/icon_search.png")
    @sprites[:icon].zoom_x = scale
    @sprites[:icon].zoom_y = scale
    @sprites[:icon].z = 1
    iconwidth = @sprites[:icon].bitmap.width * scale

    @sprites[:btnClear] = Button.new("search-box-clear", proc { clearSearch }, viewport)
    @sprites[:btnClear].scale = scale
    @sprites[:btnClear].x = self.x + self.width - @sprites[:btnClear].width - OFFSET
    @sprites[:btnClear].y = self.y + OFFSET
    @sprites[:btnClear].z = 1
    clearwidth = @sprites[:btnClear].bitmap.width * scale

    @sprites[:fillerText] = BitmapSprite.new(@width - OFFSET - iconwidth - clearwidth - OFFSET, @height, viewport)
    @sprites[:fillerText].x = @sprites[:icon].x + iconwidth + OFFSET
    @sprites[:fillerText].y = self.y
    @sprites[:fillerText].z = 10
    setSystemFont(@sprites[:fillerText].bitmap)
    @text_size = @sprites[:fillerText].bitmap.text_size("X").height
    drawFormattedTextEx(@sprites[:fillerText].bitmap, 0, (self.height - @text_size + OFFSET) / 2, @sprites[:fillerText].bitmap.width, "Click to Search", SHADOWCOLOR, SHADOWCOLOR)

    @sprites[:text] = SpriteWrapper.new(viewport)
    @sprites[:text].x = @sprites[:fillerText].x
    @sprites[:text].y = self.y
    @sprites[:text].z = 20
    @contents = doEnsureBitmap(Bitmap.new(1, 1), @sprites[:fillerText].bitmap.width, @sprites[:fillerText].bitmap.height)
    @frame = 0
    @helper = CharacterEntryHelper.new("")
  end

  def text
    @helper.text
  end

  def update
    @frame += 1
    @frame %= 40
    self.refresh if ((@frame % 20) == 0)
    if Input.triggerex?(Input::LeftMouseKey)
      mousepos = Mouse::getMousePos(true)
      if self.mouseOver?
        @sprites[:fillerText].visible = false
        @focus = true
        Input.text_input = true
      else
        @sprites[:fillerText].visible = true if self.text == ""
        @focus = false
      end
    end
    if Input.triggerex?(:ESCAPE) && @focus
      @sprites[:fillerText].visible = true if self.text == ""
      @focus = false
    end

    textEntry if @focus

    @sprites.each { |_, s| s.update }
  end

  def refresh
    width = @sprites[:fillerText].bitmap.width
    height = @sprites[:fillerText].bitmap.width
    @contents = doEnsureBitmap(@contents, width, height)
    bitmap = @contents
    @sprites[:text].bitmap = bitmap
    bitmap.clear
    textscan = self.text.scan(/./m)
    scanlength = textscan.length
    @helper.cursor = scanlength if @helper.cursor > scanlength
    @helper.cursor = 0 if @helper.cursor < 0
    fromcursor = 0
    startpos = @helper.cursor
    x = 0
    y = (self.height - @text_size) / 2
    while (startpos > 0)
      c = (@helper.passwordChar != "") ? @helper.passwordChar : textscan[startpos - 1]
      fromcursor += bitmap.text_size(c).width
      break if fromcursor > width + 2

      startpos -= 1
    end
    for i in startpos...scanlength
      c = (@helper.passwordChar != "") ? @helper.passwordChar : textscan[i]
      textwidth = bitmap.text_size(c).width
      next if c == "\n"

      # Draw text
      drawFormattedTextEx(bitmap, x, y + OFFSET / 2, textwidth, c, HIGHLIGHT, HIGHLIGHT)
      # Draw cursor if necessary
      if ((@frame / 20) & 1) == 0 && i == @helper.cursor && @focus
        bitmap.fill_rect(x, y, 2, @text_size, HIGHLIGHT)
      end
      # Add x to drawn text width
      x += textwidth
    end
    if ((@frame / 20) & 1) == 0 && textscan.length == @helper.cursor && @focus
      bitmap.fill_rect(x, y, 2, @text_size, HIGHLIGHT)
    end
  end

  def textEntry
    return if !self.focus

    # Moving cursor
    if Input.triggerex?(:LEFT) || Input.repeatex?(:LEFT)
      if @helper.cursor > 0
        @helper.cursor -= 1
        @frame = 0
        self.refresh
      end
      return
    elsif Input.triggerex?(:RIGHT) || Input.repeatex?(:RIGHT)
      if @helper.cursor < self.text.scan(/./m).length
        @helper.cursor += 1
        @frame = 0
        self.refresh
      end
      return
    elsif Input.triggerex?(:HOME)
      @helper.cursor = 0
      @frame = 0
      self.refresh
      return
    elsif Input.triggerex?(:END)
      @helper.cursor = self.text.scan(/./m).length
      @frame = 0
      self.refresh
      return
    elsif Input.pressex?(:LCTRL) && Input.triggerex?(Input::KEY_BACKSPACE)
      self.backspace if @helper.cursor > 0
      return if self.text == ""
      while self.text != "" && @helper.cursor > 0 && self.text[@helper.cursor - 1].downcase.match?(/[a-z_]/)
        self.backspace
      end
      return
    elsif Input.triggerex?(Input::KEY_BACKSPACE) || Input.repeatex?(Input::KEY_BACKSPACE) || ($joiplay && Input.trigger?(Input::B))
      self.backspace if @helper.cursor > 0
      return
    elsif Input.triggerex?(:DELETE)
      self.delete if @helper.cursor < self.text.scan(/./m).length
      return
    elsif Input.triggerex?(Input::KEY_RETURN) || Input.triggerex?(Input::KEY_ESCAPE) || ($joiplay && Input.trigger?(Input::C))
      return
    elsif Input.modifierKeyPressed?
      Input.clipboard = self.text if Input.triggerex?(:C) && self.text != nil
      if Input.triggerex?(:V)
        self.text = self.text[0...self.helper.cursor] + Input.clipboard + self.text[self.helper.cursor..]
        self.helper.cursor += Input.clipboard.length
        if self.text.length > maxlength
          self.text = self.text[0...maxlength]
          self.helper.cursor = [self.helper.cursor, maxlength].min
        end
      end
    end
    Input.gets.each_char { |c| insert(c) }
  end

  def backspace
    if @helper.delete
      @frame = 0
      self.refresh
      return true
    end
    return false
  end

  def delete
    chars = self.text.scan(/./m)
    return false if chars.length <= 0

    chars.delete_at(@helper.cursor)
    text = ""
    for ch in chars
      text += ch if ch
    end
    @helper.text = text
    @frame = 0
    self.refresh
    return true
  end

  def insert(ch)
    if @helper.insert(ch)
      @frame = 0
      self.refresh
      return true
    end
    return false
  end

  def clearSearch
    @helper.text = ""
    @focus = false
    @sprites[:fillerText].visible = true
    refresh
  end
end
