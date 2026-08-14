class ByCharLevelInterpolationCalculationPart < CalculationObject
  attr_accessor :mEndValue
  attr_accessor :mStartValue
  attr_accessor :mScalePastDefaultMaxLevel

  def to_s(percent = false, precision = nil, multiplier: 1)
    sv = @mStartValue
    ev = @mEndValue
    multiplierText = ""
    if multiplier.is_a?(Numeric) || multiplier.is_numeric?
      sv *= multiplier
      ev *= multiplier
    else
      multiplierText = " * " + multiplier.to_s(percent, precision)
    end
    return numberFormat(sv, percent, precision) + "-" + numberFormat(ev, percent, precision) + " %i:scaleLevel%#{multiplierText}"
  end
end
