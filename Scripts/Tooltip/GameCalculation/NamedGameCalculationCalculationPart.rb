class NamedGameCalculationCalculationPart < CalculationObject
  attr_accessor :mSpellCalculationKey

  def to_s(percent = false, precision = nil, multiplier: 1)
    return AugmentCache[@apiName].calcs[@mModifiedGameCalculation].to_s(multiplier: multiplier)
  end
end
