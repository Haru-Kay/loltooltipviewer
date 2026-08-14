class NumberCalculationPart < CalculationObject
  attr_accessor :mNumber

  def initialize(*args)
    super
    @numeric = true
    @quickEval = @mNumber
  end

  def to_s(percent = false, precision = nil, multiplier: 1)
    if multiplier.is_a?(Numeric) || multiplier.is_numeric?
      return numberFormat(@mNumber * multiplier, percent, precision)
    else
      return numberFormat(@mNumber) + " * " + multiplier.to_s(percent, precision)
    end
  end
end
