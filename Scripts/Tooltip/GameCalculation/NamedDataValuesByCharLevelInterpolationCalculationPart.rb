class NamedDataValuesByCharLevelInterpolationCalculationPart < CalculationObject
  attr_accessor :mDataValueStart
  attr_accessor :mDataValueEnd
  def initialize(*args)
    super
    @mDataValueStart.downcase!
    @mDataValueEnd.downcase!
  end

  def to_s(percent = false, precision = nil, multiplier: 1)
    sv = AugmentCache[@apiName].dataValues[@mDataValueStart]
    ev = AugmentCache[@apiName].dataValues[@mDataValueEnd]
    multiplierText = ""
    if multiplier.is_a?(Numeric) || multiplier.is_numeric?
      sv *= multiplier
      ev *= multiplier
    else
      multiplierText = " * " + multiplier.to_s(percent, precision)
    end
    return numberFormat(sv, percent, precision) + "-" +
      numberFormat(ev, percent, precision) + "%i:scaleLevel%#{multiplierText}"
  end
end
