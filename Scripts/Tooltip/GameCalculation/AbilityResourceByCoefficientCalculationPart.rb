class AbilityResourceByCoefficientCalculationPart < CalculationObject
  attr_accessor :mCoefficient

  def is_numeric?
    return @numeric if @numeric
    dv = AugmentCache[@apiName].dataValues[@mCoefficient]
    if dv.is_a?(Numeric)
      self.numeric = true
      self.quickEval = dv
    end
    return false
  end

  def to_s(percent = true, precision = nil, multiplier: 1)
    if multiplier.is_a?(Numeric) || multiplier.is_numeric?
      return numberFormat(@mCoefficient * multiplier, true, precision) + " %i:scaleMana%"
    else
      return numberFormat(@mCoefficient, true, precision) + " %i:scaleMana% * " + multiplier.to_s(percent, precision)
    end
  end
end
