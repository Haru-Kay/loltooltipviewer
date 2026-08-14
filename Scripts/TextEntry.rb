class Window_CharacterEntry < Window_DrawableCommand
  XSIZE = 14
  YSIZE = 4

  def initialize(charset, viewport = nil)
    @viewport = viewport
    @charset = charset
    @othercharset = ""
    super(0, 96, 480, 192)
    colors = getDefaultTextColors(self.windowskin)
    self.baseColor = colors[0]
    self.shadowColor = colors[1]
    self.columns = XSIZE
    refresh
  end

  def setOtherCharset(value)
    @othercharset = value.clone
    refresh
  end

  def setCharset(value)
    @charset = value.clone
    refresh
  end

  def character
    if self.index < 0 || self.index >= @charset.length
      return "";
    else
      return @charset[self.index]
    end
  end

  def command
    return -1 if self.index == @charset.length
    return -2 if self.index == @charset.length + 1
    return -3 if self.index == @charset.length + 2

    return self.index
  end

  def itemCount
    return @charset.length + 3
  end

  def drawItem(index, count, rect)
    rect = drawCursor(index, rect)
    if index == @charset.length # -1
      drawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height, "[ ]", self.baseColor, self.shadowColor)
    elsif index == @charset.length + 1 # -2
      drawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height, @othercharset, self.baseColor, self.shadowColor)
    elsif index == @charset.length + 2 # -3
      drawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height, _INTL("OK"), self.baseColor, self.shadowColor)
    else
      drawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height, @charset[index], self.baseColor, self.shadowColor)
    end
  end
end

class CharacterEntryCursor
  def initialize(viewport)
    @sprite = SpriteWrapper.new(viewport)
    @cursortype = 0
    @cursor1 = AnimatedBitmap.new("Graphics/Pictures/Naming/namingCursor1")
    @cursor2 = AnimatedBitmap.new("Graphics/Pictures/Naming/namingCursor2")
    @cursor3 = AnimatedBitmap.new("Graphics/Pictures/Naming/namingCursor3")
    @cursorPos = 0
    updateInternal
  end

  def setCursorPos(value)
    @cursorPos = value
  end

  def updateCursorPos
    if @cursorPos == CharacterGridEntryScene::UPPER
      @sprite.x = 48
      @sprite.y = 120
      @cursortype = 1
    elsif @cursorPos == CharacterGridEntryScene::LOWER
      @sprite.x = 112
      @sprite.y = 120
      @cursortype = 1
    elsif @cursorPos == CharacterGridEntryScene::SYMBOLS
      @sprite.x = 176
      @sprite.y = 120
      @cursortype = 1
    elsif @cursorPos == CharacterGridEntryScene::BACK
      @sprite.x = 312
      @sprite.y = 120
      @cursortype = 2
    elsif @cursorPos == CharacterGridEntryScene::OK
      @sprite.x = 392
      @sprite.y = 120
      @cursortype = 2
    elsif @cursorPos >= 0
      @sprite.x = 52  + 32 * (@cursorPos % CharacterGridEntryScene::COLUMNS)
      @sprite.y = 180 + 38 * (@cursorPos / CharacterGridEntryScene::COLUMNS)
      @cursortype = 0
    end
  end

  def visible=(value)
    @sprite.visible = value
  end

  def visible
    @sprite.visible
  end

  def color=(value)
    @sprite.color = value
  end

  def color
    @sprite.color
  end

  def disposed?
    @sprite.disposed?
  end

  def updateInternal
    @cursor1.update
    @cursor2.update
    @cursor3.update
    updateCursorPos
    case @cursortype
      when 0
        @sprite.bitmap = @cursor1.bitmap
      when 1
        @sprite.bitmap = @cursor2.bitmap
      when 2
        @sprite.bitmap = @cursor3.bitmap
    end
  end

  def update
    updateInternal
  end

  def dispose
    @cursor1.dispose
    @cursor2.dispose
    @cursor3.dispose
    @sprite.dispose
  end
end

class CharacterEntryHelper
  attr_reader :text
  attr_reader :maxlength
  attr_reader :passwordChar
  attr_accessor :cursor

  def text=(value)
    @text = value
  ensure
  end

  def textChars
    chars = text.scan(/./m)
    if @passwordChar != ""
      chars.length.times { |i|
        chars[i] = @passwordChar
      }
    end
    return chars
  end

  def initialize(text)
    @maxlength = -1
    @text = text
    @passwordChar = ""
    @cursor = text.scan(/./m).length
  ensure
  end

  def passwordChar=(value)
    @passwordChar = value ? value : ""
  end

  def maxlength=(value)
    @maxlength = value
  ensure
  end

  def length
    return self.text.scan(/./m).length
  end

  def canInsert?
    chars = self.text.scan(/./m)
    return false if @maxlength >= 0 && chars.length >= @maxlength

    return true
  end

  def insert(ch)
    chars = self.text.scan(/./m)
    return false if @maxlength >= 0 && chars.length >= @maxlength

    chars.insert(@cursor, ch)
    @text = ""
    for ch in chars
      @text += ch if ch
    end
    @cursor += 1
    return true
  end

  def canDelete?
    chars = self.text.scan(/./m)
    return false if chars.length <= 0 || @cursor <= 0

    return true
  end

  def delete
    chars = self.text.scan(/./m)
    return false if chars.length <= 0 || @cursor <= 0

    chars.delete_at(@cursor - 1)
    @text = ""
    for ch in chars
      @text += ch if ch
    end
    @cursor -= 1
    return true
  end

  private

  def ensure
    return if @maxlength < 0

    chars = self.text.scan(/./m)
    if chars.length > @maxlength && @maxlength >= 0
      chars = chars[0, @maxlength]
    end
    @text = ""
    for ch in chars
      @text += ch if ch
    end
  end
end

class Window_TextEntry < SpriteWindow_Base
  def initialize(text, x, y, width, height, heading = nil, usedarkercolor = false)
    super(x, y, width, height)
    colors = getDefaultTextColors(self.windowskin)
    @baseColor = colors[0]
    @shadowColor = colors[1]
    if usedarkercolor
      @baseColor = Color.new(16, 24, 32)
      @shadowColor = Color.new(168, 184, 184)
    end
    @helper = CharacterEntryHelper.new(text)
    @heading = heading
    self.active = true
    @frame = 0
    refresh
  end

  def text
    @helper.text
  end

  def maxlength
    @helper.maxlength
  end

  def passwordChar
    @helper.passwordChar
  end

  def text=(value)
    @helper.text = value
    self.refresh
  end

  def passwordChar=(value)
    @helper.passwordChar = value
    refresh
  end

  def maxlength=(value)
    @helper.maxlength = value
    self.refresh
  end

  def insert(ch)
    if @helper.insert(ch)
      @frame = 0
      self.refresh
      return true
    end
    return false
  end

  def delete
    if @helper.delete
      @frame = 0
      self.refresh
      return true
    end
    return false
  end

  def update
    @frame += 1
    @frame %= 20
    self.refresh if ((@frame % 10) == 0)
    return if !self.active

    # Moving cursor
    if Input.repeat?(Input::LEFT) && Input.press?(Input::A)
      if @helper.cursor > 0
        @helper.cursor -= 1
        @frame = 0
        self.refresh
      end
      return
    end
    if Input.repeat?(Input::RIGHT) && Input.press?(Input::A)
      if @helper.cursor < self.text.scan(/./m).length
        @helper.cursor += 1
        @frame = 0
        self.refresh
      end
      return
    end
    # Backspace
    if Input.repeat?(Input::B)
      self.delete if @helper.cursor > 0
      return
    end
  end

  def refresh
    self.contents = doEnsureBitmap(self.contents, self.width - self.borderX, self.height - self.borderY)
    bitmap = self.contents
    bitmap.clear
    x = 0
    y = 0
    if @heading
      textwidth = bitmap.text_size(@heading).width
      drawShadowText(bitmap, x, y, textwidth + 4, 32, @heading, @baseColor, @shadowColor)
      y += 32
    end
    x += 4
    width = self.width - self.borderX
    height = self.height - self.borderY
    cursorcolor = Color.new(16, 24, 32)
    textscan = self.text.scan(/./m)
    scanlength = textscan.length
    @helper.cursor = scanlength if @helper.cursor > scanlength
    @helper.cursor = 0 if @helper.cursor < 0
    startpos = @helper.cursor
    fromcursor = 0
    while (startpos > 0)
      c = (@helper.passwordChar != "") ? @helper.passwordChar : textscan[startpos - 1]
      fromcursor += bitmap.text_size(c).width
      break if fromcursor > width - 4

      startpos -= 1
    end
    for i in startpos...scanlength
      c = (@helper.passwordChar != "") ? @helper.passwordChar : textscan[i]
      textwidth = bitmap.text_size(c).width
      next if c == "\n"

      # Draw text
      drawShadowText(bitmap, x, y, textwidth + 4, 32, c, @baseColor, @shadowColor)
      # Draw cursor if necessary
      if ((@frame / 10) & 1) == 0 && i == @helper.cursor
        bitmap.fill_rect(x, y + 4, 2, 24, cursorcolor)
      end
      # Add x to drawn text width
      x += textwidth
    end
    if ((@frame / 10) & 1) == 0 && textscan.length == @helper.cursor
      bitmap.fill_rect(x, y + 4, 2, 24, cursorcolor)
    end
  end
end

class Window_MultilineTextEntry < SpriteWindow_Base
  def initialize(text, x, y, width, height)
    super(x, y, width, height)
    colors = getDefaultTextColors(self.windowskin)
    @baseColor = colors[0]
    @shadowColor = colors[1]
    @helper = CharacterEntryHelper.new(text)
    @firstline = 0
    @cursorLine = 0
    @cursorColumn = 0
    @frame = 0
    self.active = true
    refresh
  end

  attr_reader :baseColor
  attr_reader :shadowColor

  def baseColor=(value)
    @baseColor = value
    refresh
  end

  def shadowColor=(value)
    @shadowColor = value
    refresh
  end

  def text
    @helper.text
  end

  def maxlength
    @helper.maxlength
  end

  def text=(value)
    @helper.text = value
    @textchars = nil
    self.refresh
  end

  def maxlength=(value)
    @helper.maxlength = value
    @textchars = nil
    self.refresh
  end

  def insert(ch)
    @helper.cursor = getPosFromLineAndColumn(@cursorLine, @cursorColumn)
    if @helper.insert(ch)
      @frame = 0
      @textchars = nil
      moveCursor(0, 1)
      self.refresh
      return true
    end
    return false
  end

  def delete
    @helper.cursor = getPosFromLineAndColumn(@cursorLine, @cursorColumn)
    if @helper.delete
      @frame = 0
      moveCursor(0, -1) # use old textchars
      @textchars = nil
      self.refresh
      return true
    end
    return false
  end

  def getTextChars
    if !@textchars
      @textchars = getLineBrokenText(self.contents, @helper.text, self.contents.width, nil)
    end
    return @textchars
  end

  def getTotalLines
    textchars = getTextChars
    if textchars.length == 0
      return 1
    else
      tchar = textchars[textchars.length - 1]
      return tchar[5] + 1
    end
  end

  def getLineY(line)
    textchars = getTextChars
    if textchars.length == 0
      return 0
    else
      totallines = getTotalLines()
      line = 0 if line < 0
      line = totallines - 1 if line >= totallines
      maximumY = 0
      for i in 0...textchars.length
        thisline = textchars[i][5]
        y = textchars[i][2]
        return y if thisline == line

        maximumY = y if maximumY < y
      end
      return maximumY
    end
  end

  def getColumnsInLine(line)
    textchars = getTextChars
    if textchars.length == 0
      return 0
    else
      totallines = getTotalLines()
      line = 0 if line < 0
      line = totallines - 1 if line >= totallines
      endpos = 0
      for i in 0...textchars.length
        thisline = textchars[i][5]
        thispos = textchars[i][6]
        thislength = textchars[i][8]
        if thisline == line
          endpos += thislength
        end
      end
      return endpos
    end
  end

  def getPosFromLineAndColumn(line, column)
    textchars = getTextChars
    if textchars.length == 0
      return 0
    else
      totallines = getTotalLines()
      line = 0 if line < 0
      line = totallines - 1 if line >= totallines
      endpos = 0
      for i in 0...textchars.length
        thisline = textchars[i][5]
        thispos = textchars[i][6]
        thiscolumn = textchars[i][7]
        thislength = textchars[i][8]
        if thisline == line
          endpos = thispos + thislength
          #         echoln [endpos,thispos+(column-thiscolumn),textchars[i]]
          if column >= thiscolumn && column <= thiscolumn + thislength && thislength > 0
            return thispos + (column - thiscolumn)
          end
        end
      end
      if endpos == 0
        #       echoln [totallines,line,column]
        #       echoln textchars
      end
      #     echoln "endpos=#{endpos}"
      return endpos
    end
  end

  def getLastVisibleLine
    textchars = getTextChars()
    textheight = [1, self.contents.text_size("X").height].max
    lastVisible = @firstline + ((self.height - self.borderY) / textheight) - 1
    return lastVisible
  end

  def getLineBrokenText(bitmap, value, width, dims)
    x = 0
    y = 0
    textheight = 0
    ret = []
    if dims
      dims[0] = 0
      dims[1] = 0
    end
    line = 0
    position = 0
    column = 0
    return ret if !bitmap || bitmap.disposed? || width <= 0

    textmsg = value.clone
    lines = 0
    color = Font.default_color
    ret.push(["", 0, 0, 0, bitmap.text_size("X").height, 0, 0, 0, 0])
    while ((c = textmsg.slice!(/\n|(\S*([ \r\t\f]?))/)) != nil)
      break if c == ""

      length = c.scan(/./m).length
      ccheck = c
      if ccheck == "\n"
        ret.push(["\n", x, y, 0, textheight, line, position, column, 0])
        x = 0
        y += (textheight == 0) ? bitmap.text_size("X").height : textheight
        line += 1
        textheight = 0
        column = 0
        position += length
        ret.push(["", x, y, 0, textheight, line, position, column, 0])
        next
      end
      textcols = []
      words = [ccheck]
      for i in 0...words.length
        word = words[i]
        if word && word != ""
          textSize = bitmap.text_size(word)
          textwidth = textSize.width
          if x > 0 && x + textwidth >= width - 2
            # Zero-length word break
            ret.push(["", x, y, 0, textheight, line, position, column, 0])
            x = 0
            column = 0
            y += (textheight == 0) ? bitmap.text_size("X").height : textheight
            line += 1
            textheight = 0
          end
          textheight = [textheight, textSize.height].max
          ret.push([word, x, y, textwidth, textheight, line, position, column, length])
          x += textwidth
          dims[0] = x if dims && dims[0] < x
        end
        if textcols[i]
          color = textcols[i]
        end
      end
      position += length
      column += length
    end
    dims[1] = y + textheight if dims
    return ret
  end

  def updateCursorPos(doRefresh)
    # Calculate new cursor position
    @helper.cursor = getPosFromLineAndColumn(@cursorLine, @cursorColumn)
    if doRefresh
      @frame = 0
      self.refresh
    end
    if @cursorLine < @firstline
      @firstline = @cursorLine
    end
    lastVisible = getLastVisibleLine()
    if @cursorLine > lastVisible
      @firstline += (@cursorLine - lastVisible)
    end
  end

  def moveCursor(lineOffset, columnOffset)
    # Move column offset first, then lines (since column offset
    # can affect line offset)
    #   echoln ["beforemoving",@cursorLine,@cursorColumn]
    totalColumns = getColumnsInLine(@cursorLine) # check current line
    totalLines = getTotalLines()
    oldCursorLine = @cursorLine
    oldCursorColumn = @cursorColumn
    @cursorColumn += columnOffset
    if @cursorColumn < 0 && @cursorLine > 0
      # Will happen if cursor is moved left from the beginning of a line
      @cursorLine -= 1
      @cursorColumn = getColumnsInLine(@cursorLine)
    elsif @cursorColumn > totalColumns && @cursorLine < totalLines - 1
      # Will happen if cursor is moved right from the end of a line
      @cursorLine += 1
      @cursorColumn = 0
      updateColumns = true
    end
    # Ensure column bounds
    totalColumns = getColumnsInLine(@cursorLine)
    @cursorColumn = totalColumns if @cursorColumn > totalColumns
    @cursorColumn = 0 if @cursorColumn < 0 # totalColumns can be 0
    # Move line offset
    @cursorLine += lineOffset
    @cursorLine = 0 if @cursorLine < 0
    @cursorLine = totalLines - 1 if @cursorLine >= totalLines
    # Ensure column bounds again
    totalColumns = getColumnsInLine(@cursorLine)
    @cursorColumn = totalColumns if @cursorColumn > totalColumns
    @cursorColumn = 0 if @cursorColumn < 0 # totalColumns can be 0
    updateCursorPos(
      oldCursorLine != @cursorLine ||
      oldCursorColumn != @cursorColumn
    )
    #   echoln ["aftermoving",@cursorLine,@cursorColumn]
  end

  def update
    @frame += 1
    @frame %= 20
    self.refresh if ((@frame % 10) == 0)
    return if !self.active

    # Moving cursor
    if Input.triggerex?(:LEFT) || Input.repeatex?(:LEFT)
      moveCursor(0, -1)
      return
    elsif Input.triggerex?(:UP) || Input.repeatex?(:UP)
      moveCursor(-1, 0)
      return
    elsif Input.triggerex?(:DOWN) || Input.repeatex?(:DOWN)
      moveCursor(1, 0)
      return
    elsif Input.triggerex?(:RIGHT) || Input.repeatex?(:RIGHT)
      moveCursor(0, 1)
      return
    elsif Input.triggerex?(:HOME)
      # Move cursor to beginning
      @cursorLine = 0
      @cursorColumn = 0
      updateCursorPos(true)
      return
    elsif Input.triggerex?(:END)
      # Move cursor to end
      @cursorLine = getTotalLines() - 1
      @cursorColumn = getColumnsInLine(@cursorLine)
      updateCursorPos(true)
      return
    elsif Input.triggerex?(Input::KEY_RETURN) || Input.repeatex?(Input::KEY_RETURN) || ($joiplay && Input.trigger?(Input::C))
      self.insert("\n")
      return
    elsif Input.triggerex?(Input::KEY_BACKSPACE) || Input.repeatex?(Input::KEY_BACKSPACE) || ($joiplay && Input.trigger?(Input::B))
      self.delete
      return
    end
    Input.gets.each_char { |c| insert(c) }
  end

  def refresh
    newContents = doEnsureBitmap(self.contents, self.width - self.borderX, self.height - self.borderY)
    @textchars = nil if self.contents != newContents
    self.contents = newContents
    bitmap = self.contents
    bitmap.clear
    getTextChars
    height = self.height - self.borderY
    cursorcolor = Color.new(0, 0, 0)
    textchars = getTextChars()
    startY = getLineY(@firstline)
    for i in 0...textchars.length
      thisline = textchars[i][5]
      thiscolumn = textchars[i][7]
      thislength = textchars[i][8]
      textY = textchars[i][2] - startY
      # Don't draw lines before the first or zero-length segments
      next if thisline < @firstline || thislength == 0
      # Don't draw lines beyond the window's height
      break if textY >= height

      c = textchars[i][0]
      # Don't draw spaces
      next if c == " "

      textwidth = textchars[i][3] + 4 # add 4 to prevent draw_text from stretching text
      textheight = textchars[i][4]
      # Draw text
      drawShadowText(bitmap, textchars[i][1], textY, textwidth, textheight, c, @baseColor, @shadowColor)
    end
    # Draw cursor
    if ((@frame / 10) & 1) == 0
      textheight = bitmap.text_size("X").height
      cursorY = (textheight * @cursorLine) - startY
      cursorX = 0
      for i in 0...textchars.length
        thisline = textchars[i][5]
        thiscolumn = textchars[i][7]
        thislength = textchars[i][8]
        if thisline == @cursorLine && @cursorColumn >= thiscolumn &&
           @cursorColumn <= thiscolumn + thislength
          cursorY = textchars[i][2] - startY
          cursorX = textchars[i][1]
          textheight = textchars[i][4]
          posToCursor = @cursorColumn - thiscolumn
          if posToCursor >= 0
            partialString = textchars[i][0].scan(/./m)[0, posToCursor].join("")
            cursorX += bitmap.text_size(partialString).width
          end
          break
        end
      end
      cursorY += 4
      cursorHeight = [4, textheight - 4, bitmap.text_size("X").height - 4].max
      bitmap.fill_rect(cursorX, cursorY, 2, cursorHeight, cursorcolor)
    end
  end
end

class Window_TextEntry_Keyboard < Window_TextEntry
  def update
    @frame += 1
    @frame %= 20
    self.refresh if ((@frame % 10) == 0)
    return if !self.active

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
    elsif Input.triggerex?(Input::KEY_BACKSPACE) || Input.repeatex?(Input::KEY_BACKSPACE) || ($joiplay && Input.trigger?(Input::B))
      self.delete if @helper.cursor > 0
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

  def helper
    return @helper
  end
end

class Window_BoundedTextEntry_Keyboard < Window_TextEntry
  attr_reader :matchingnames
  attr_accessor :highlightindex
  attr_accessor :highlightoffset

  def initialize(text, names, x, y, width, height, heading = nil, usedarkercolor = false)
    @names = names
    @backnames = []
    @matchingnames = names
    @highlightindex = -1
    @highlightoffset = 0
    calculateNextChar(0)
    super(text, x, y, width, height, heading, usedarkercolor)
  end

  def update
    @frame += 1
    @frame %= 20
    self.refresh if ((@frame % 10) == 0)
    return if !self.active
    # No moving cursor
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
    elsif (Input.triggerex?(:UP) || Input.repeatex?(:UP)) && @highlightindex > 0
      @highlightindex -= 1
      @highlightindex = @matchingnames.length if @highlightindex == 0
    elsif (Input.triggerex?(:PAGEUP) || Input.repeatex?(:PAGEUP)) && @highlightindex > 0
      @highlightindex -= 5
      @highlightindex = 1 if @highlightindex <= 0
    elsif Input.triggerex?(:DOWN) || Input.repeatex?(:DOWN)
      @highlightindex += 1 if @highlightindex == -1
      @highlightindex += 1
      @highlightindex = 1 if @highlightindex > @matchingnames.length
    elsif (Input.triggerex?(:PAGEDOWN) || Input.repeatex?(:PAGEDOWN)) && @highlightindex > 0
      @highlightindex += 5
      @highlightindex = @matchingnames.length if @highlightindex > @matchingnames.length
    elsif Input.triggerex?(Input::KEY_BACKSPACE) || Input.repeatex?(Input::KEY_BACKSPACE) || Input.triggerGamepad?(Input::B)
      if @helper.cursor > 0
        @matchingnames, @nextchars = @backnames.pop
        self.delete
      end
      return
    elsif Input.triggerex?(Input::KEY_RETURN) || Input.triggerex?(Input::KEY_ESCAPE) || Input.triggerGamepad?(Input::C)
      return
    elsif Input.triggerex?(:TAB)
      if @highlightindex > 0 && @highlightindex <= @matchingnames.length
        nextdisplay = @matchingnames[@highlightindex - 1]
        nextdisplay = nextdisplay[self.text.length..nextdisplay.length]

        for c in nextdisplay.chars
          c = c.downcase
          matches = @matchingnames.select { |n| n[self.text.length] && n[self.text.length].downcase == c }
          if !matches.empty?
            reup = @matchingnames.all? { |n| n[self.text.length]&.upcase == n[self.text.length] }
            @backnames.push([@matchingnames, @nextchars])
            @matchingnames = matches
            calculateNextChar(self.text.length)
            c = c.upcase if reup
            insert(c)
          end
          recapitalize
        end
      else
        for c in 0...@nextchars.length
          @backnames.push([@matchingnames, @nextchars[c..@nextchars.length]])
        end
        complete = @nextchars
        @nextchars = ""
        for c in complete.chars
          insert(c)
        end
        recapitalize
      end
    end

    Input.gets.each_char { |c|
      c = c.downcase
      matches = @matchingnames.select { |n| n[self.text.length] && n[self.text.length].downcase == c }
      if !matches.empty?
        reup = @matchingnames.all? { |n| n[self.text.length]&.upcase == n[self.text.length] }
        @backnames.push([@matchingnames, @nextchars])
        @matchingnames = matches
        calculateNextChar(self.text.length)
        c = c.upcase if reup
        insert(c)
      end
      recapitalize
    }
  end

  def insert(c)
    super(c)
    @highlightindex = -1
    @highlightoffset = 0
  end

  def recapitalize
    for i in 0...self.text.length - 1
      reup = @matchingnames.all? { |n| n[i].upcase == n[i] }
      self.text[i] = self.text[i].upcase if reup
      self.text[i] = self.text[i].downcase unless reup
    end
  end

  def calculateNextChar(currentlength)
    @nextchars = ""
    strings = @matchingnames.map { |n| n[(currentlength + 1)...n.length] }

    shortest = strings.min_by &:length
    maxlen = shortest.length
    maxlen.downto(0) do |len|
      0.upto(maxlen - len) do |start|
        substr = shortest[start,len]
        if strings.all? {|str| str.start_with? substr }
          @nextchars = substr
          return
        end
      end
    end
  end

  def isMatch?
    return @matchingnames.length == 1
  end

  def refresh
    self.contents = doEnsureBitmap(self.contents, self.width - self.borderX,
       self.height - self.borderY)
    bitmap = self.contents
    bitmap.clear
    x = 0
    y = 0
    if @heading
      textwidth = bitmap.text_size(@heading).width
      drawShadowText(bitmap, x, y, textwidth + 4, 32, @heading, @baseColor, @shadowColor)
      y += 32
    end
    x += 4
    width = self.width - self.borderX
    height = self.height - self.borderY
    cursorcolor = Color.new(16, 24, 32)
    textscan = self.text.scan(/./m)
    scanlength = textscan.length
    @helper.cursor = scanlength if @helper.cursor > scanlength
    @helper.cursor = 0 if @helper.cursor < 0
    startpos = @helper.cursor
    fromcursor = 0
    while startpos > 0
      c = (@helper.passwordChar != "") ? @helper.passwordChar : textscan[startpos - 1]
      fromcursor += bitmap.text_size(c).width
      break if fromcursor > width-4
      startpos -= 1
    end
    for i in startpos...scanlength
      c = (@helper.passwordChar != "") ? @helper.passwordChar : textscan[i]
      textwidth = bitmap.text_size(c).width
      next if c == "\n"
      # Draw text
      drawShadowText(bitmap, x, y, textwidth+4, 32, c, @baseColor, @shadowColor)
      # Draw cursor if necessary
      if ((@frame / 10) & 1) == 0 && i == @helper.cursor
        bitmap.fill_rect(x, y + 4, 2, 24, cursorcolor)
      end
      # Add x to drawn text width
      x += textwidth
    end
    if ((@frame / 10) & 1) == 0 && textscan.length == @helper.cursor
      bitmap.fill_rect(x, y + 4, 2, 24, cursorcolor)
    end
    nextdisplay = @nextchars
    if @highlightindex > 0 && @highlightindex <= @matchingnames.length
      nextdisplay = @matchingnames[@highlightindex - 1]
      nextdisplay = nextdisplay[self.text.length..nextdisplay.length]
    end
    textwidth = bitmap.text_size(nextdisplay).width
    drawShadowText(bitmap, x, y, textwidth + 4, 32, nextdisplay, @shadowColor, nil)
  end
end

def freeText(msgwindow, currenttext, maxlength, width, past_texts, passwordbox)
  window = Window_TextEntry_Keyboard.new(currenttext, 0, 0, width, 64)
  Input.text_input = true
  ret = ""
  window.maxlength = maxlength
  window.visible = true
  window.z = 99999
  positionNearMsgWindow(window, msgwindow, :right)
  # Move it to the top of the screen on JoiPlay so that it isn't covered by keyboard
  window.y = 0 if $joiplay && $Settings.useKeyboard?
  window.text = currenttext
  window.passwordChar = "*" if passwordbox
  past_text_index = 0
  past_texts.unshift(currenttext)
  loop do
    Graphics.update
    Input.update
    if Input.trigger?(Input::UP) && past_text_index < (past_texts.length - 1) && $DEBUG
      past_texts[0] = window.text if past_text_index == 0
      past_text_index += 1
      window.text = past_texts[past_text_index]
      window.helper.cursor = window.text.length
    end
    if Input.trigger?(Input::DOWN) && past_text_index > 0 && $DEBUG
      past_text_index -= 1
      window.text = past_texts[past_text_index]
      window.helper.cursor = window.text.length
    end
    if Input.triggerex?(Input::KEY_ESCAPE) || ($joiplay && Input.trigger?(Input::B))
      ret = currenttext
      break
    end
    if Input.triggerex?(Input::KEY_RETURN) || ($joiplay && Input.trigger?(Input::C))
      ret = window.text
      break
    end
    window.update
    msgwindow.update if msgwindow
    yield if block_given?
  end
  window.dispose
  Input.update
  Input.text_input = false
  past_texts.shift
  return ret
end

def messageFreeText(message, currenttext, maxlength, width = 240, past_texts = [], passwordbox: false, &block)
  unless $Settings.useKeyboard?
    # Use the entry scene instead when keyboard is disabled
    scene = CharacterGridEntryScene.new
    screen = TextEntry.new(scene)
    maxlength = 20 if maxlength > 20
    return screen.startScreen(message, 0, maxlength, currenttext)
  end

  msgwindow = createMessageWindow
  retval = messageDisplay(
    msgwindow, message, true,
    proc { |msgwindow|
      next freeText(msgwindow, currenttext, maxlength, width, past_texts, passwordbox, &block)
    },
    &block
  )
  disposeMessageWindow(msgwindow)
  return retval
end

#===============================================================================
# Text entry screen - free typing.
#===============================================================================
class TextEntryScene
  @@Characters = [
    [("ABCDEFGHIJKLM NOPQRSTUVWXYZ abcdefghijklm nopqrstuvwxyz ").scan(/./), "[*]"],
    [("0123456789    !@\#$%^&*()    ~`-_+={}[]    :;'\"<>,.?/    ").scan(/./), "[A]"],
  ]

  def startScene(helptext, minlength, maxlength, initialText, subject = 0)
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    subjectspace = subject != 0 ? 88 : 0
    if $Settings.useKeyboard?
      @sprites["entry"] = Window_TextEntry_Keyboard.new(initialText, 0, 0, 400 - subjectspace, 96, helptext, true)
      Input.text_input = true
    else # Should never get here since CharacterGridEntry exists
      @sprites["entry"] = Window_TextEntry.new(initialText, 0, 0, 400 - subjectspace, 96, helptext, true)
    end
    @sprites["entry"].x = (Graphics.width / 2) - (@sprites["entry"].width / 2) + (subjectspace / 2)
    @sprites["entry"].viewport = @viewport
    @sprites["entry"].visible = true
    @minlength = minlength
    @maxlength = maxlength
    @symtype = 0
    @sprites["entry"].maxlength = maxlength
    if !$Settings.useKeyboard?
      @sprites["entry2"] = Window_CharacterEntry.new(@@Characters[@symtype][0])
      @sprites["entry2"].setOtherCharset(@@Characters[@symtype][1])
      @sprites["entry2"].viewport = @viewport
      @sprites["entry2"].visible = true
      @sprites["entry2"].x = (Graphics.width / 2) - (@sprites["entry2"].width / 2)
    end
    if minlength == 0
      @sprites["helpwindow"] = Window_UnformattedText.newWithSize(
        _INTL("Enter text using the keyboard.  Press\nESC to cancel, or ENTER to confirm."),
        32, Graphics.height - 96, Graphics.width - 64, 96, @viewport
      )
    else
      @sprites["helpwindow"] = Window_UnformattedText.newWithSize(
        _INTL("Enter text using the keyboard.\nPress ENTER to confirm."),
        32, Graphics.height - 96, Graphics.width - 64, 96, @viewport
      )
    end
    @sprites["helpwindow"].letterbyletter = false
    @sprites["helpwindow"].viewport = @viewport
    @sprites["helpwindow"].visible = $Settings.useKeyboard?
    @sprites["helpwindow"].baseColor = Color.new(16, 24, 32)
    @sprites["helpwindow"].shadowColor = Color.new(168, 184, 184)
    addBackgroundPlane(@sprites, "background", "Naming/naming2bg", @viewport)
    # case subject
    # when
    # else
    # end
    fadeInAndShow(@sprites)
  end

  def entry1
    ret = ""
    loop do
      Graphics.update
      Input.update
      if (Input.triggerex?(Input::KEY_ESCAPE) || ($joiplay && Input.trigger?(Input::B))) && @minlength == 0
        ret = ""
        break
      elsif (Input.triggerex?(Input::KEY_RETURN) || ($joiplay && Input.trigger?(Input::C))) && @sprites["entry"].text.length >= @minlength
        ret = @sprites["entry"].text
        break
      end
      @sprites["helpwindow"].update
      @sprites["entry"].update
      @sprites["subject"].update if @sprites["subject"]
    end
    Input.update
    return ret
  end

  def entry2
    ret = ""
    loop do
      Graphics.update
      Input.update
      @sprites["helpwindow"].update
      @sprites["entry"].update
      @sprites["entry2"].update
      @sprites["subject"].update if @sprites["subject"]
      if Input.trigger?(Input::C)
        index = @sprites["entry2"].command
        if index == -3 # Confirm text
          ret = @sprites["entry"].text
          if ret.length < @minlength || ret.length > @maxlength

          else

            break
          end
        elsif index == -1 # Insert a space
          if @sprites["entry"].insert(" ")

          else

          end
        elsif index == -2 # Change character set
          @symtype += 1
          @symtype = 0 if @symtype >= @@Characters.length
          @sprites["entry2"].setCharset(@@Characters[@symtype][0])
          @sprites["entry2"].setOtherCharset(@@Characters[@symtype][1])
        else # Insert given character
          if @sprites["entry"].insert(@sprites["entry2"].character)
          else

          end
        end
        next
      end
    end
    Input.update
    return ret
  end

  def entry
    return $Settings.useKeyboard? ? entry1 : entry2
  end

  def endScene
    Input.text_input = false if $Settings.useKeyboard?
    fadeOutAndHide(@sprites)
    disposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
# Text entry screen - arrows to select letter.
#===============================================================================
class CharacterGridEntryScene
  @@Characters = [
    [("ABCDEFGHIJ ,." +  "KLMNOPQRST '-" + "UVWXYZ     ♂♀" +  "             " + "0123456789   ").scan(/./), _INTL("UPPER")],
    [("abcdefghij ,." +  "klmnopqrst '-" + "uvwxyz     ♂♀" +  "             " + "0123456789   ").scan(/./), _INTL("lower")],
    [(",.:;!?   ♂♀  " + "\"'()<>[]     " + "~@#%*&$      " + "+-=^_/\\|     " + "             ").scan(/./), _INTL("other")],
  ]
  COLUMNS = 13
  ROWS = 5
  UPPER = -5
  LOWER = -4
  SYMBOLS = -3
  BACK = -2
  OK = -1

  KEYBOARDTEXTBASECOLOR = Color.new(16, 24, 32)
  KEYBOARDTEXTSHADOWCOLOR = Color.new(160, 160, 160)
  CHARACTER_WIDTH = 20

  def startScene(helptext, minlength, maxlength, initialText, subject = 0)
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @helptext = helptext
    @helper = CharacterEntryHelper.new(initialText)
    @baseTabBitmaps = [
       AnimatedBitmap.new("Graphics/Pictures/Naming/namingTab1"),
       AnimatedBitmap.new("Graphics/Pictures/Naming/namingTab2"),
       AnimatedBitmap.new("Graphics/Pictures/Naming/namingTab3")
    ]
    @tabBitmaps = @baseTabBitmaps.map { |it| BitmapWrapper.new(it.width, it.height) }
    for i in 0...3
      bmp = @tabBitmaps[i]
      base = @baseTabBitmaps[i]
      bmp.blt(0, 0, base.bitmap, Rect.new(0, 0, base.width, base.height))

      charPos = 0
      setSystemFont(bmp)
      textPos = []
      for y in 0...ROWS
        for x in 0...COLUMNS
          textPos.push([@@Characters[i][0][charPos], 44 + x * 32, 18 + y * 38, 2, KEYBOARDTEXTBASECOLOR, KEYBOARDTEXTSHADOWCOLOR])
          charPos += 1
        end
      end
      drawTextPositions(bmp, textPos)
    end
    @blankBitmap = BitmapWrapper.new(CHARACTER_WIDTH, 6)
    @blankBitmap.fill_rect(2, 2, CHARACTER_WIDTH - 2, 4, Color.new(168, 184, 184))
    @blankBitmap.fill_rect(0, 0, CHARACTER_WIDTH - 2, 4, Color.new(16, 24, 32))
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/Naming/namingbg")
    # case subject
    #   else
    # end
    @sprites["bgoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    updateTextEntryOverlay
    @mode = 0
    @minlength = minlength
    @maxlength = maxlength
    @maxlength.times {|i|
       @sprites["blank#{i}"] = SpriteWrapper.new(@viewport)
       @sprites["blank#{i}"].bitmap = @blankBitmap
       @sprites["blank#{i}"].x = horizontalOffset() + CHARACTER_WIDTH * i
    }
    @sprites["bottomtab"] = SpriteWrapper.new(@viewport) # Current tab
    @sprites["bottomtab"].x = 22
    @sprites["bottomtab"].y = 162
    @sprites["bottomtab"].bitmap = @tabBitmaps[0]
    @sprites["toptab"] = SpriteWrapper.new(@viewport) # Next tab
    @sprites["toptab"].x = 22 - 504
    @sprites["toptab"].y = 162
    @sprites["toptab"].bitmap = @tabBitmaps[1]
    @sprites["controls"] = IconSprite.new(0,0,@viewport)
    @sprites["controls"].setBitmap("Graphics/Pictures/Naming/namingControls")
    @sprites["controls"].x = 16
    @sprites["controls"].y = 96
    @forceUpdate = true
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    updateControlsOverlay
    @sprites["cursor"] = CharacterEntryCursor.new(@viewport)
    @cursorpos = 0
    @refreshOverlay = true
    @sprites["cursor"].setCursorPos(@cursorpos)
    fadeInAndShow(@sprites) { update }
  end

  def horizontalOffset # Matches normal entry scene
    return 160 - (@sprites["subject"] ? 0 : 88)
  end

  def updateOverlay
    @refreshOverlay = true
  end

  def updateControlsOverlay
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    modeIcon = [["Graphics/Pictures/Naming/namingMode", 48 + @mode * 64, 120, @mode * 60, 0, 60, 44]]
    drawImagePositions(overlay, modeIcon)
  end

  def updateTextEntryOverlay
    return if !@refreshOverlay
    @refreshOverlay = false
    bgoverlay = @sprites["bgoverlay"].bitmap
    bgoverlay.clear
    setSystemFont(bgoverlay)
    textPositions = [
       [@helptext, horizontalOffset(), 12, false, Color.new(16, 24, 32), Color.new(168, 184, 184)]
    ]
    chars = @helper.textChars
    x = horizontalOffset() + 4
    for ch in chars
      textPositions.push([ch, x, 48, false, Color.new(16, 24, 32), Color.new(168, 184, 184)])
      x += CHARACTER_WIDTH
    end
    drawTextPositions(bgoverlay, textPositions)
  end

  def changeTab(tab = @mode + 1)
    tab %= 3
    @sprites["cursor"].visible = false
    @sprites["toptab"].bitmap = @tabBitmaps[tab]
    21.times do
      @sprites["toptab"].x += 24
      @sprites["bottomtab"].y += 12
      Graphics.update
      Input.update
      update
    end
    tempx = @sprites["toptab"].x
    @sprites["toptab"].x = @sprites["bottomtab"].x
    @sprites["bottomtab"].x = tempx

    tempy = @sprites["toptab"].y
    @sprites["toptab"].y = @sprites["bottomtab"].y
    @sprites["bottomtab"].y = tempy

    tempbitmap = @sprites["toptab"].bitmap
    @sprites["toptab"].bitmap = @sprites["bottomtab"].bitmap
    @sprites["bottomtab"].bitmap = tempbitmap

    Graphics.update
    Input.update

    update
    @mode = tab
    newtab = @tabBitmaps[(tab + 1) % 3]
    @sprites["cursor"].visible = true
    @sprites["toptab"].bitmap = newtab
    @sprites["toptab"].x = 22 - 504
    @sprites["toptab"].y = 162
    updateControlsOverlay
  end

  def update
    for i in 0...3
      @baseTabBitmaps[i].update
    end
    if @forceUpdate || Graphics.frame_count % 5 == 0
      @forceUpdate = false
      cursorpos = @helper.cursor
      cursorpos = @maxlength-1 if cursorpos >= @maxlength
      cursorpos = 0 if cursorpos < 0
      @maxlength.times { |i|
        @sprites["blank#{i}"].y = (i == cursorpos) ? 82 : 78
      }
    end
    updateTextEntryOverlay
    updateSpriteHash(@sprites)
  end

  def columnEmpty?(m)
    return false if m >= COLUMNS - 1
    chset = @@Characters[@mode][0]
    return (
       chset[m] == " " &&
       chset[m + (COLUMNS - 1)] == " " &&
       chset[m + (COLUMNS - 1) * 2] == " " &&
       chset[m + (COLUMNS - 1) * 3] == " "
    )
  end

  def wrapmod(x, y)
    result = x % y
    result += y if result < 0
    return result
  end

  def moveCursor
    oldcursor = @cursorpos
    cursorRow = @cursorpos / COLUMNS
    cursorCol = @cursorpos % COLUMNS
    cursororigin = @cursorpos - cursorCol
    if Input.repeat?(Input::LEFT)
      if @cursorpos < 0 # Controls
        @cursorpos -= 1
        @cursorpos = OK if @cursorpos < UPPER
      else
        begin
          cursorCol = wrapmod(cursorCol - 1, COLUMNS)
          @cursorpos = cursororigin + cursorCol
        end while columnEmpty?(cursorCol)
      end
    elsif Input.repeat?(Input::RIGHT)
      if @cursorpos < 0 # Controls
        @cursorpos += 1
        @cursorpos = UPPER if @cursorpos > OK
      else
        begin
          cursorCol = wrapmod(cursorCol + 1, COLUMNS)
          @cursorpos = cursororigin + cursorCol
        end while columnEmpty?(cursorCol)
      end
    elsif Input.repeat?(Input::UP)
      if @cursorpos < 0 # Controls
        case @cursorpos
          when UPPER
            @cursorpos = COLUMNS * (ROWS - 1)
          when LOWER
            @cursorpos = COLUMNS * (ROWS - 1) + 2
          when SYMBOLS
            @cursorpos = COLUMNS * (ROWS - 1) + 4
          when BACK
            @cursorpos = COLUMNS * (ROWS - 1) + 8
          when OK
            @cursorpos = COLUMNS * (ROWS - 1) + 11
        end
      elsif @cursorpos < COLUMNS # Top row of letters
        case @cursorpos
          when 0, 1
            @cursorpos = UPPER
          when 2, 3
            @cursorpos = LOWER
          when 4, 5, 6
            @cursorpos = SYMBOLS
          when 7, 8, 9, 10
            @cursorpos = BACK
          when 11, 12
            @cursorpos = OK
        end
      else
        cursorRow = wrapmod(cursorRow - 1, ROWS)
        @cursorpos = cursorRow * COLUMNS + cursorCol
      end
    elsif Input.repeat?(Input::DOWN)
      if @cursorpos < 0 # Controls
        case @cursorpos
          when UPPER
            @cursorpos = 0
          when LOWER
            @cursorpos = 2
          when SYMBOLS
            @cursorpos = 4
          when BACK
            @cursorpos = 8
          when OK
            @cursorpos = 11
        end
      elsif @cursorpos >= COLUMNS * (ROWS - 1) # Bottom row of letters
        case @cursorpos - COLUMNS * (ROWS - 1)
          when 0, 1
            @cursorpos = UPPER
          when 2, 3
            @cursorpos = LOWER
          when 4, 5, 6
            @cursorpos = SYMBOLS
          when 7, 8, 9, 10
            @cursorpos = BACK
          when 11, 12
            @cursorpos = OK
        end
      else
        cursorRow = wrapmod(cursorRow + 1, ROWS)
        @cursorpos = cursorRow * COLUMNS + cursorCol
      end
    end
    if @cursorpos != oldcursor # Cursor position changed
      @sprites["cursor"].setCursorPos(@cursorpos)
      return true
    else
      return false
    end
  end

  def hittest
    mousepos = Mouse::getMousePos
    return false if !mousepos
    mousepos[0] -= $ResizeOffsetX if defined?($ResizeOffsetX)
    mousepos[1] -= $ResizeOffsetX if defined?($ResizeOffsetY)

    rising = Input.triggerex?(Input::LeftMouseKey)
    falling = Input.releaseex?(Input::LeftMouseKey)
    if falling
      # Only allow OK to be hit if you click it twice
      okAllowed = @canHitOk
      @canHitOk = @cursorpos == OK
    end

    return false unless rising || falling

    oldcursor = @cursorpos
    if mousepos[0] >= 44 && mousepos[1] < 86 # Blanks/Text
      if mousepos[0] >= 160 && mousepos[0] < (160 + 24 * @maxlength)
        if rising
          pos = (mousepos[0] - 160) / 24
          realpos = pos
          realpos = @helper.length if pos > @helper.length

          if @helper.cursor != pos
            @helper.cursor = realpos
          end
        end
      end
    elsif mousepos[1] >= 124 && mousepos[1] < 162 # Controls row
      if mousepos[0] >= 50 && mousepos[0] < 106 # Upper button
        if rising
          @cursorpos = UPPER
        elsif falling && @cursorpos == UPPER
          return true
        end
      elsif mousepos[0] >= 114 && mousepos[0] < 170 # lower button
        if rising
          @cursorpos = LOWER
        elsif falling && @cursorpos == LOWER
          return true
        end
      elsif mousepos[0] >= 178 && mousepos[0] < 234 # Others button
        if rising
          @cursorpos = SYMBOLS
        elsif falling && @cursorpos == SYMBOLS
          return true
        end
      elsif mousepos[0] >= 314 && mousepos[0] < 384 # Back button
        if rising
          @cursorpos = BACK
        elsif falling && @cursorpos == BACK
          return true
        end
      elsif mousepos[0] >= 394 && mousepos[0] < 474 # OK button
        if rising
          @cursorpos = OK
        elsif falling && @cursorpos == OK
          if okAllowed
            return true
          else
          end
        end
      end
    elsif mousepos[1] >= 184 && mousepos[1] < 378 # Character grid
      if mousepos[0] >= 48 && mousepos[0] < 468
        if mousepos[0] <= 50
          hitx = 0
        elsif mousepos[0] >= 466
          hitx = 12
        else
          hitx = (mousepos[0] - 50) / 32
        end

        if mousepos[1] <= 186
          hity = 0
        elsif mousepos[1] >= 376
          hity = 4
        else
          hity = (mousepos[1] - 186) / 38
        end

        target = hity * COLUMNS + hitx

        if rising
          @cursorpos = target
        elsif falling && @cursorpos == target
          return true
        end
      end
    end

    if @cursorpos != oldcursor # Cursor position changed
      @sprites["cursor"].setCursorPos(@cursorpos)
    end

    return false
  end

  def entry
    ret = ""
    loop do
      Graphics.update
      Input.update
      update
      next if moveCursor
      if Input.trigger?(Input::B)
        @helper.delete
        updateOverlay
      elsif Input.trigger?(Input::C) || hittest
        if @cursorpos == BACK # Backspace
          @helper.delete
          updateOverlay
        elsif @cursorpos == OK # Done
          if @helper.length >= @minlength
            ret = @helper.text
            break
          end
        elsif @cursorpos == UPPER
          changeTab(0) if @mode != 0
        elsif @cursorpos == LOWER
          changeTab(1) if @mode != 1
        elsif @cursorpos == SYMBOLS
          changeTab(2) if @mode != 2
        else
          cursorCol = @cursorpos % COLUMNS
          cursorRow = @cursorpos / COLUMNS
          charpos = cursorRow * COLUMNS + cursorCol
          chset = @@Characters[@mode][0]
          if @helper.length >= @maxlength
            @helper.delete
          end
          @helper.insert(chset[charpos])
          if @helper.length >= @maxlength
            @cursorpos = OK
            @sprites["cursor"].setCursorPos(@cursorpos)
          end
          updateOverlay
        end
      elsif Input.trigger?(Input::L)
        @helper.cursor -= 1
        @helper.cursor = @helper.length if @helper.cursor < 0
      elsif Input.trigger?(Input::R)
        @helper.cursor += 1
        @helper.cursor = 0 if @helper.cursor > @helper.length
      elsif Input.trigger?(Input::Y)
        @cursorpos = OK
        @sprites["cursor"].setCursorPos(@cursorpos)
      elsif Input.trigger?(Input::X)
        changeTab
      end
    end
    Input.update
    return ret
  end

  def endScene
    fadeOutAndHide(@sprites) { update }

    for bitmap in @baseTabBitmaps
      bitmap.dispose if bitmap
    end

    for bitmap in @tabBitmaps
      bitmap.dispose if bitmap
    end

    @blankBitmap.dispose
    disposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
# Text entry with options to choose from and auto-complete
#===============================================================================
class BoundedTextEntryScene
  def startScene(helptext, names)
    @names = names

    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @sprites["entry"] = Window_BoundedTextEntry_Keyboard.new("", names, 0, 0, 400, 96, helptext, true)
    Input.text_input = true

    @sprites["entry"].x = (Graphics.width / 2) - (@sprites["entry"].width / 2)
    @sprites["entry"].viewport = @viewport
    @sprites["entry"].visible = true

    @sprites["helpwindow"] = Window_UnformattedText.newWithSize(
      _INTL("Enter text using the keyboard.  Press\nESC to cancel, or ENTER to confirm."),
      32, Graphics.height - 96, Graphics.width - 64, 96, @viewport
    )

    hintwidth = names.map { |n| @sprites["entry"].contents.text_size(n).width }.max
    @sprites["matchwindow"] = Window_UnformattedText.newWithSize("", 32, 96, hintwidth + 88, Graphics.height - 192, @viewport)

    matchtxt, overlay_y, overlaytxt = updateMatches

    @sprites["matchwindow"].text = matchtxt
    @sprites["matchwindow"].visible = true
    @sprites["matchwindow"].viewport = @viewport
    @sprites["matchwindow"].letterbyletter = false
    @sprites["matchwindow"].baseColor = Color.new(16, 24, 32)
    @sprites["matchwindow"].shadowColor = Color.new(168, 184, 184)

    @sprites["helpwindow"].letterbyletter = false
    @sprites["helpwindow"].viewport = @viewport
    @sprites["helpwindow"].visible = true
    @sprites["helpwindow"].baseColor = Color.new(16, 24, 32)
    @sprites["helpwindow"].shadowColor = Color.new(168, 184, 184)

    @sprites["matchoverlay"] = Window_UnformattedText.newWithSize("", 44, overlay_y, hintwidth + 88, 96, @viewport)
    @sprites["matchoverlay"].text = overlaytxt
    @sprites["matchoverlay"].visible = true
    @sprites["matchoverlay"].viewport = @viewport
    @sprites["matchoverlay"].letterbyletter = false
    @sprites["matchoverlay"].baseColor = LightColorArrays[:Blue][0]
    @sprites["matchoverlay"].shadowColor = LightColorArrays[:Blue][1]

    addBackgroundPlane(@sprites, "background", "Naming/naming2bg", @viewport)

    # After background plane so that the box still renders
    @sprites["matchwindow"].setSkin("Graphics/Windowskins/speech naming")

    fadeInAndShow(@sprites)
  end

  def updateMatches
    limit = 5
    matchesdisplayed = []
    heights = []
    totalheight = 0

    skipped = 0

    if @sprites["entry"].highlightindex == -1
      @sprites["entry"].highlightoffset = 0
    else
      while @sprites["entry"].highlightoffset + limit < @sprites["entry"].highlightindex
        @sprites["entry"].highlightoffset += 1
      end

      while @sprites["entry"].highlightoffset > @sprites["entry"].highlightindex - 1
        @sprites["entry"].highlightoffset -= 1
      end
    end

    for i in @sprites["entry"].matchingnames[@sprites["entry"].highlightoffset, limit]
      height = @sprites["entry"].contents.text_size(i).height
      heights.push(totalheight)
      totalheight += height + 2
      matchesdisplayed.push(i)
    end

    if @sprites["entry"].highlightindex > 0
      idx = @sprites["entry"].highlightindex - 1 - @sprites["entry"].highlightoffset
      return matchesdisplayed.join("\n"), @sprites["matchwindow"].y + heights[idx], matchesdisplayed[idx]
    end
    return matchesdisplayed.join("\n"), @sprites["matchwindow"].y, ""
  end

  def entry
    ret = ""
    loop do
      Graphics.update
      Input.update
      if Input.triggerex?(Input::KEY_ESCAPE) || Input.triggerGamepad?(Input::B)
        ret = ""
        break
      elsif Input.triggerex?(Input::KEY_RETURN) || Input.triggerGamepad?(Input::C)
        if @sprites["entry"].isMatch?
          ret = @sprites["entry"].matchingnames[0]
          break
        elsif @sprites["entry"].highlightindex > 0 && @sprites["entry"].highlightindex <= @sprites["entry"].matchingnames.length
          ret = @sprites["entry"].matchingnames[@sprites["entry"].highlightindex - 1]
          break
        end
      end
      @sprites["helpwindow"].update
      lastmatchnames = @sprites["entry"].matchingnames
      lasthighlightindex = @sprites["entry"].highlightindex
      @sprites["entry"].update
      if lastmatchnames != @sprites["entry"].matchingnames || lasthighlightindex != @sprites["entry"].highlightindex
        matchtxt, overlay_y, overlaytxt = updateMatches
        @sprites["matchwindow"].text = matchtxt
        @sprites["matchoverlay"].y = overlay_y
        @sprites["matchoverlay"].text = overlaytxt
      end
    end
    Input.update
    return ret
  end

  def endScene
    Input.text_input = false
    fadeOutAndHide(@sprites)
    disposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class TextEntry
  def initialize(scene)
    @scene = scene
  end

  def startScreen(helptext, minlength, maxlength, initialText, mode = 0)
    @scene.startScene(helptext, minlength, maxlength, initialText, mode)
    ret = @scene.entry
    @scene.endScene
    return ret
  end
end

def enterBoundedText(helptext, keys, noitemstext, &nameMapper)
  names = keys.map { |key| (block_given? ? nameMapper.call(key) : key).gsub('é', 'e') }
  names, keys = names.zip(keys).sort_by { |it| it[0] }.transpose

  ret = ""
  if names.nil? || names.length == 0
    showMessage(noitemstext)
  else
    fadeOutIn(99999){
      sscene = BoundedTextEntryScene.new
      sscene.startScene(helptext, names)
      ret = sscene.entry
      sscene.endScene
    }
  end
  ret = names&.index(ret)
  return nil if ret.nil?
  return keys[ret]
end

def enterText(helptext, minlength, maxlength, initialText = "", mode = 0)
  ret = ""
  fadeOutIn(99999) {
    if $Settings.useKeyboard?
      sscene = TextEntryScene.new
    else
      sscene = CharacterGridEntryScene.new
    end
    sscreen = TextEntry.new(sscene)
    ret = sscreen.startScreen(helptext, minlength, maxlength, initialText, mode)
  }
  return ret
end
