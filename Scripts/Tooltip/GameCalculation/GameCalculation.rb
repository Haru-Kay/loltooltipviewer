class GameCalculation < CalculationObject
  attr_accessor :mDisplayAsPercent
  attr_accessor :mExpandedTooltipCalculationDisplay
  attr_accessor :mFormulaParts
  attr_accessor :mSimpleTooltipCalculationDisplay
  attr_accessor :mMultiplier
  attr_accessor :SomeFlagBroIDK
  attr_accessor :tooltipOnly
  attr_accessor :mPrecision

  def to_s(percent = false, precision = nil, multiplier: 1)
    str = "("
    multiplier = multiplier * @mMultiplier if @mMultiplier&.is_numeric?
    if @mFormulaParts.all? { |s| s.is_numeric? }
      total = 0
      @mFormulaParts.each { |s| total += s.quickEval }
      multiplierText = ""
      if multiplier.is_a?(Numeric) || multiplier.is_numeric?
        total *= multiplier
      else
        multiplierText = " * " + multiplier.to_s(percent, precision)
      end
      color = "<c=F0E6D2>"
      str += color
      str += numberFormat(total, @mDisplayAsPercent, @mPrecision) + multiplierText
      str += "</c>"
    else
      @mFormulaParts.each_with_index { |s, i|
        color = "<c=F0E6D2>"
        if s.instance_variables.include?(:@mStat)
          stat = FORMATTING[("scale" + STATNAMES[s.mStat]).to_sym] || FORMATTING[:scaleBonus]
          color = "<c=#{stat[:color]}>"
        end
        str += color
        str += " +" if i != 0
        str += s.to_s(@mDisplayAsPercent, @mPrecision, multiplier: multiplier)
        str += "</c>"
      }
    end
    str += ")"
    return str
  end
end
