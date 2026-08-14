class BuffCounterByCoefficientCalculationPart < CalculationObject
  attr_accessor :mBuffName
  attr_accessor :mCoefficient
  attr_accessor :mIconKey

  def to_s(percent = false, precision = nil, multiplier: 1)
    if multiplier.is_a?(Numeric) || multiplier.is_numeric?
      return numberFormat(@mCoefficient * multiplier, percent, precision) + " per " + @mIconKey
    else
      return numberFormat(@mCoefficient, percent, precision) + " per " + @mIconKey + " * " + multiplier.to_s(percent, precision)
    end
  end
end
