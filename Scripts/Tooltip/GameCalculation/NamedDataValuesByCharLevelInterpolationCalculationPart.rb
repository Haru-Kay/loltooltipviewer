class NamedDataValuesByCharLevelInterpolationCalculationPart < CalculationObject
  attr_accessor :StartDataValue
  attr_accessor :EndDataValue
  def initialize(*args)
    super
    @StartDataValue.downcase!
    @EndDataValue.downcase!
  end

  def to_s(percent = false, precision = nil, multiplier: 1)
    sv = AugmentCache[@apiName].dataValues[@StartDataValue]
    ev = AugmentCache[@apiName].dataValues[@EndDataValue]
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
