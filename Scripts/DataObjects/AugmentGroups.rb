class AugmentGroup
  attr_accessor :name, :augments
  def initialize(name, augments)
    @name = name
    @augments = augments
  end

  def include?(obj)
    return @augments.include?(obj)
  end
end
