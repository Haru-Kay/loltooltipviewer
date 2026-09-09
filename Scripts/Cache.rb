class LOLCache
  attr_accessor :augments
  attr_accessor :groups
  attr_accessor :champions

  def load
    cacheAugments
    cacheGroups
    cacheChamps
  end

  def cacheAugments
    compileAugments if !fileExists?("Data/mayhem.dat")# || $DEBUG
    @augments = load_data("Data/mayhem.dat")
  end

  def cacheGroups
    compileAugmentGroups if !fileExists?("Data/mayhemGroups.dat") #|| $DEBUG
    @groups = load_data("Data/mayhemGroups.dat")
  end

  def cacheChamps
    compileChamps if !fileExists?("Data/champions.dat") || $DEBUG
    @champions = load_data("Data/champions.dat")
  end
end

class LOLHashWrapper
  attr_accessor :data
  def initialize(value = nil)
    @data = value || {}
  end

  def [](value)
    if value.is_a?(Numeric)
      return @data.find { |_, v| v.id == value } || @data.values[value]
    end
    if value.is_a?(String) || value.is_a?(Symbol)
      value = value.to_s
      value = value[1..] if value.start_with?("@")
      return @data[value]
    end
    return nil
  end

  def method_missing(method, *args, &block)
    if @data.respond_to?(method)
      @data.send(method, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(method, include_private = false)
    @data.respond_to?(method) || super
  end
end
