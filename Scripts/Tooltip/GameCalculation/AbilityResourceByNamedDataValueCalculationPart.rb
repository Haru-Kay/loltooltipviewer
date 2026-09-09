class AbilityResourceByNamedDataValueCalculationPart < CalculationObject
  attr_accessor :DataValue
  def initialize(*args)
    super
    @DataValue.downcase!
  end

  def to_s(percent = false, precision = nil, multiplier: 1)
    if multiplier.is_a?(Numeric) || multiplier.is_numeric?
      return numberFormat($cache.augments[@apiName].dataValues[@DataValue] * multiplier) + " %i:scaleMana%"
    else
      return numberFormat($cache.augments[@apiName].dataValues[@DataValue]) + " %i:scaleMana%" + " * " + multiplier.to_s(percent, precision)
    end
  end
end
