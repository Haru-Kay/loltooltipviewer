class BuffCounterByNamedDataValueCalculationPart < CalculationObject
  attr_accessor :mBuffName
  attr_accessor :mDataValue
  def initialize(*args)
    super
    @mDataValue.downcase!
  end

  def to_s(percent = false, precision = nil, multiplier: 1)
    if multiplier.is_a?(Numeric) || multiplier.is_numeric?
      return numberFormat($cache.augments[@apiName].dataValues[@mDataValue] * multiplier) + " per %i:iconDefault%"
    else
      return numberFormat($cache.augments[@apiName].dataValues[@mDataValue]) + " per %i:iconDefault%" + " * " + multiplier.to_s(percent, precision)
    end
  end
end
