class ProductOfSubPartsCalculationPart < CalculationObject
  attr_accessor :mPart1
  attr_accessor :mPart2

  def to_s(percent = false, precision = nil, multiplier: 1)
    @mPart1.is_numeric?; @mPart2.is_numeric?
    if @mPart1.is_numeric? && @mPart2.is_numeric?
      if multiplier.is_a?(Numeric) || multiplier.is_numeric?
        return numberFormat(@mPart1.quickEval * @mPart2.quickEval * multiplier, percent, precision)
      else
        return numberFormat(@mPart1.quickEval * @mPart2.quickEval) + " * " + multiplier.to_s(percent, precision)
      end
    else
      return @mPart1.to_s(multiplier: multiplier) + " * " + @mPart2.to_s(multiplier: multiplier)
    end
  end
end
