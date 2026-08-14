class Augment
  attr_accessor :id
  attr_accessor :apiName
  attr_accessor :name
  attr_accessor :rarity
  attr_accessor :desc
  attr_accessor :tooltip
  attr_accessor :dataValues
  attr_accessor :calculations
  attr_accessor :calcs
  attr_accessor :quest
  attr_accessor :icons
  attr_accessor :add
  attr_accessor :disabled

  def initialize(json)
    json.each { |k, v|
      case k
        when "calculations", "calcs"
          v.each { |calcKey, calc|
            t = calc["~class"]
            t = t[1...].upcase if t.start_with?("0x")
            v[calcKey] = Object.const_get(t).new(@apiName, calc)
            v[calcKey].instance_variable_set(:@mPrecision, 0) if ["RangeIncrease"].include?(calcKey)
            v[calcKey].instance_variable_set(:@mPrecision, 1) if ["MaxShredTooltipOnly"].include?(calcKey)
            if t == "GameCalculation"
              v[calcKey].mFormulaParts.each { |part|
                next unless part.is_a?(NamedDataValueCalculationPart) || part.is_a?(AbilityResourceByNamedDataValueCalculationPart)
                quickEval = :@mDataValue if part.is_a?(NamedDataValueCalculationPart)
                quickEval = :@DataValue if part.is_a?(AbilityResourceByNamedDataValueCalculationPart)

                namedValue = part.instance_variable_get(quickEval).downcase
                value = @dataValues[namedValue]
                if value.is_a?(Numeric)
                  part.numeric = true
                  part.quickEval = value
                else
                  $missingValues ||= []
                  $missingValues.push([@name, namedValue])
                end
              }
            end
          }
        when "add"
          v = Augment.new(v)
        when "quest"
          v = QuestData.new(v)
        when "dataValues"
          v = v.transform_keys { |v| v.downcase }
      end
      self.instance_variable_set("@" + k, v)
    }
    @dataValues ||= {}
  end

  def name
    name = @name
    name = @name + " <c=BD1E37>(Disabled)</c>" if @disabled
    return name
  end

  def icon(large = true)
    return @icons[large ? 1 : 0]
  end

  def tooltip
    return @tooltipFilled if @tooltipFilled
    desc = fillDescription(@tooltip.dup)

    if @quest&.TooltipOverride
      desc = ""
      @quest.TooltipOverride.each_with_index { |t, i|
        @questtier = i
        desc += "<c=F0C200><b>Level #{i}</b></c>\n  " + fillDescription(t.dup) + "\n\n"
      }
    end

    @tooltipFilled = desc

    return @tooltipFilled
  end

  def fillDescription(text)
    while text[/@.*?@/]
      match = $~.to_s
      text = $~.pre_match + getTextVariable(match) + $~.post_match
    end
    while text[/@.*?@/]
      match = $~.to_s
      text = $~.pre_match + getTextVariable(match) + $~.post_match
    end
    return text
  end

  def getTextVariable(var)
    var = var[1...-1] if var.start_with?("@")

    if var[/f[0-9]+/]
      return 0.to_s
    end

    mult = 1
    if var.include?("*")
      var, mult = var.split("*")
      mult = mult.to_f
    end

    if @dataValues[var.downcase]
      s = @dataValues[var.downcase]
      s *= mult
      s = s.round(2)
      s = s.to_i if s == s.round
      return s.to_s
    end

    return @questtier.to_s if var == "QuestTier"

    if calcs[var]
      return calcs[var].to_s
    end

    return var
  end

  def calcs
    return @calculations || @calcs || {}
  end

  def to_s

  end
end
