class NamedDataValueCalculationPart < CalculationObject
  attr_accessor :mDataValue

  def initialize(*args)
    super
    @mDataValue.downcase!
  end

  def is_numeric?
    return @numeric if @numeric
    dv = AugmentCache[@apiName].dataValues[@mDataValue]
    if dv.is_a?(Numeric)
      self.numeric = true
      self.quickEval = dv
      return true
    end
    return false
  end

  def to_s(percent = false, precision = nil, multiplier: 1)
    if multiplier.is_a?(Numeric) || multiplier.is_numeric?
      return numberFormat(AugmentCache[@apiName].dataValues[@mDataValue] * multiplier, percent, precision)
    else
      return numberFormat(AugmentCache[@apiName].dataValues[@mDataValue], percent, precision) + " * " + multiplier.to_s(percent, precision)
    end
  end
end
