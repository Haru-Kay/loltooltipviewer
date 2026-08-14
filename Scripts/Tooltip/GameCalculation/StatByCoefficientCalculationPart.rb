class StatByCoefficientCalculationPart < CalculationObject
  attr_accessor :mCoefficient
  attr_accessor :mStat

  def initialize(*args)
    @mStat = 0
    @mStatFormula = 0
    super
  end

  def to_s(percent = true, precision = nil, multiplier: 1)
    if multiplier.is_a?(Numeric) || multiplier.is_numeric?
      return numberFormat(@mCoefficient * multiplier, true, precision) + " " + getStatDisplay(@mStat, @mStatFormula)
    else
      return numberFormat(@mCoefficient, true, precision) + " " + getStatDisplay(@mStat, @mStatFormula) + " * " + multiplier.to_s(percent, precision)
    end
  end
end
