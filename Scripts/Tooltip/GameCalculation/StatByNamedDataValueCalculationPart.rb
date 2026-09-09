class StatByNamedDataValueCalculationPart < CalculationObject
  attr_accessor :mDataValue
  attr_accessor :mStat
  attr_accessor :mStatFormula

  def initialize(*args)
    @mStat = 0
    @mStatFormula = 0
    super
    @mDataValue.downcase!
  end

  def to_s(percent = false, precision = nil, multiplier: 1)
    if multiplier.is_a?(Numeric) || multiplier.is_numeric?
      return numberFormat($cache.augments[@apiName].dataValues[@mDataValue] * multiplier, true, precision) + " " + getStatDisplay(@mStat, @mStatFormula)
    else
      return numberFormat($cache.augments[@apiName].dataValues[@mDataValue], true, precision) + " " + getStatDisplay(@mStat, @mStatFormula) + " * " + multiplier.to_s(percent, precision)
    end
  end
end
