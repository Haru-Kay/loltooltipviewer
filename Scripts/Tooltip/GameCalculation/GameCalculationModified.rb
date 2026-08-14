class GameCalculationModified < CalculationObject
  attr_accessor :mModifiedGameCalculation
  attr_accessor :mMultiplier
  attr_accessor :mExpandedTooltipCalculationDisplay
  attr_accessor :mSimpleTooltipCalculationDisplay
  attr_accessor :tooltipOnly

  def to_s(percent = false, precision = nil)
    return AugmentCache[@apiName].calcs[@mModifiedGameCalculation].to_s(multiplier: @mMultiplier)
  end
end
