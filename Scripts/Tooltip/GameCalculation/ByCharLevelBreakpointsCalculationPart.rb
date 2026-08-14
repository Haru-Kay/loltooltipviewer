class ByCharLevelBreakpointsCalculationPart < CalculationObject
  attr_accessor :mBreakpoints
  attr_accessor :mLevel1Value
  attr_accessor :mInitialBonusPerLevel

  def to_s(percent = false, precision = nil, multiplier: 1)
    levels = [1]
    bpoints = []
    v = @mLevel1Value
    multiplierText = multiplier == 1 ? "" : " * " + multiplier.to_s(percent, precision)
    if @mBreakpoints
      bpoints.push(numberFormat(v, percent, precision))
      @mBreakpoints.each { |b|
        v += (b.mAdditionalBonusAtThisLevel)
        levels.push(b.mLevel)
        bpoints.push(numberFormat(v, percent, precision))
      }
      text = bpoints.join("/")
      text += " (#{levels.join("/")} %i:scaleLevel%#{multiplierText})"
      return text
    else
      return numberFormat(v, percent, precision) + " plus " + numberFormat(@mInitialBonusPerLevel, percent, precision) + " per level#{multiplierText}"
    end
  end
end
