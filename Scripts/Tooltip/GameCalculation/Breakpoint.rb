class Breakpoint < CalculationObject
  attr_accessor :mAdditionalBonusAtThisLevel
  attr_accessor :mLevel

  def to_s(percent = false, precision = nil, multiplier: 1)
    if multiplier.is_a?(Numeric) || multiplier.is_numeric?
      return (@mAdditionalBonusAtThisLevel * multiplier).to_s
    else
      return numberFormat(@mAdditionalBonusAtThisLevel, true, precision) + "% %i:scaleMana% * " + multiplier.to_s(percent, precision)
    end
  end
end
