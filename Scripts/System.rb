module Input
  # JoiPlay doesn't support symbols so we need to use constants
  KEY_RETURN = $joiplay ? 0x42 : 0x0D
  KEY_ESCAPE = $joiplay ? 0x6f : 0x1B
  KEY_BACKSPACE = $joiplay ? 0x04 : 0x08

  class << Input
    alias update_KGC_ScreenCapture update unless method_defined?(:update_KGC_ScreenCapture)
  end

  # On Mac, basic keyboard shortcuts are typically bound to Command (⌘) instead of Control. Command + C for copy, etc.
  # LGUI is the Left Command key, and RGUI is the Right Command key. On Windows, the Windows key would be the equivalent.
  def self.modifierKeyPressed?
    if System.platform[/macOS/]
      return pressex?(:LGUI) || pressex?(:RGUI)
    end
    return press?(Input::CTRL)
  end

  # Shift key is mapped to Input::A on joiplay mkxp, so we use H key instead (key code 72)
  def self.shiftKeyTriggered?
    return self.triggerex?(72) if $joiplay
    return (defined?(Input::D) && self.trigger?(Input::D)) || Input::Controller.axes_trigger[1] >= 0.1
  end

  def self.shiftKeyPressed?
    return self.pressex?(72) if $joiplay
    return (defined?(Input::D) && self.press?(Input::D)) || Input::Controller.axes_trigger[1] >= 0.1
  end

  def self.triggerexAny?(keys)
    keys.each do |key|
      return true if triggerex?(key)
    end
    return false
  end

  def self.repeatexAny?(keys)
    keys.each do |key|
      return true if repeatex?(key)
    end
    return false
  end

  def self.update
    update_KGC_ScreenCapture

    if triggerex?(:F6)
      begin
        Input.text_input = true
        $past_texts = [] if !$past_texts
        code = messageFreeText(_INTL("What code would you like to run?"), "", 999, Graphics.width, $past_texts)
        $past_texts.unshift(code) unless code == ""
        $past_texts.uniq!
        eval(code)
        Input.text_input = false
      rescue
        logError($!, display: true)
        Input.text_input = false
      end
    end
  end

  def self.triggerGamepad?(key)
    return false if !$joiplay && last_device == :KBM
    return true if trigger?(key)
    return false
  end
end

def setWindowText(string = System.game_title)
  System.set_window_title(string)
end
