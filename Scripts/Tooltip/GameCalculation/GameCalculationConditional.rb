class GameCalculationConditional < CalculationObject
  attr_accessor :mConditionalCalculationRequirements
  attr_accessor :mConditionalGameCalculation
  attr_accessor :mDefaultGameCalculation
  attr_accessor :mExpandedTooltipCalculationDisplay
  attr_accessor :mSimpleTooltipCalculationDisplay

  def to_s(percent = false, precision = nil, multiplier: 1)
    return @mDefaultGameCalculation.to_s + " %i:meleeActive%/" + @mConditionalGameCalculation.to_s + " %i:rangedActive%"
  end
end
