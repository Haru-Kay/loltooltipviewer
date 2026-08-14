class RangedModifiableGameCalculation < CalculationObject
  attr_accessor :mExpandedTooltipCalculationDisplay
  attr_accessor :mFormulaParts
  attr_accessor :mRangedMultiplier
  attr_accessor :mSimpleTooltipCalculationDisplay
  attr_accessor :mDisplayAsPercent
  attr_accessor :ResultModifier
  attr_accessor :mMultiplier

  def to_s(percent = false, precision = nil, multiplier: 1)
    melee = ""
    ranged = ""
    if @mFormulaParts.all? { |s| s.is_numeric? } && @mRangedMultiplier.is_numeric?
      total = 0
      @mFormulaParts.each { |s| total += s.quickEval }
      total *= multiplier
      color = "<c=F0E6D2>"
      melee += color
      melee += numberFormat(total, @mDisplayAsPercent, @mPrecision)
      melee += "</c>"

      ranged = numberFormat(total * @mRangedMultiplier.quickEval, @mDisplayAsPercent, @mPrecision)
    else
      @mFormulaParts.each_with_index { |s, i|
        color = "<c=F0E6D2>"
        if s.instance_variables.include?(:@mStat)
          stat = FORMATTING[("scale" + STATNAMES[s.mStat]).to_sym] || FORMATTING[:scaleBonus]
          color = "<c=#{stat[:color]}>"
        end
        melee += color
        melee += " +" if i != 0
        melee += s.to_s(@mDisplayAsPercent, @mPrecision, multiplier: multiplier)
        ranged = melee.dup
        melee += "</c>"

        ranged += " * " + @mRangedMultiplier.to_s(@mDisplayAsPercent, @mPrecision, multiplier: multiplier)
      }
    end
    return "(" + melee + " %i:meleeActive% | " + ranged + " %i:rangedActive% )"
  end
end
