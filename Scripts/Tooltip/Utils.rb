module AugmentRarities
  Silver = 0
  Gold = 1
  Prismatic = 2
end

class CalculationObject
  attr_accessor :quickEval
  attr_accessor :numeric
  def initialize(apiName, json)
    @apiName = apiName
    json.each { |k, v|
      next if k == "~class"
      v = createSubClass(@apiName, v)
      self.instance_variable_set("@" + k, v)
    }
    @numeric = false
    @quickEval = nil
  end

  def is_numeric?
    @numeric
  end

  def to_f
    @numeric ? @quickEval : 1
  end

  def coerce(v)
    [v, self.to_f]
  end
end

def numberFormat(num, percentage = false, precision = nil)
  precision ||= 1
  while num < 10**(-1 * precision)
    precision += 1
  end
  s = num
  # yes this is cringe
  perPer = percentage && s < 0.005 - (2 * 10**(-10))
  s *= 100 if percentage
  s *= 100 if perPer
  s = s.round(precision)
  s = s.to_i if s == s.round
  s = s.to_s
  s += "%" if percentage
  s += " per 100" if perPer
  return s
end

STATNAMES = {
  0 => "AP", 1 => "Armor", 2 => "AD", 4 => "AS", 6 => "MR", 7 => "MS", 8 => "Crit", 9 => "CritMult", 10 => "CDR",
  11 => "AbilityHaste",  12 => "Health", 13 => "Health", 17 => "Dodge", 18 => "Lifesteal", 19 => "Spellvamp",
  20 => "Omnivamp", 22 => "MagicPenFlat", 23 => "MagicPercentPen", 27 => "ArmorPercentPen", 28 => "ArmorBonusPercentPen",
  29 => "Lethality", 30 => "Tenacity", 31 => "Attack Range", 32 => "Health Regen", 33 => "Mana Regen", 34 => "HealShield",
}
STATICONS = {
  0 => "AP", 1 => "Armor", 2 => "AD", 4 => "AS", 6 => "MR", 7 => "MS", 8 => "Crit", 9 => "CritMult", 10 => "CDR",
  11 => "Cooldown",  12 => "Health", 13 => "Health", 17 => "Dodge", 18 => "LS", 19 => "SV",
  20 => "SV", 22 => "MPen", 23 => "MPen", 26 => "APen", 27 => "APen", 28 => "APen", 29 => "APen", 30 => "Tenacity",
  31 => "Range", 32 => "Health Regen", 33 => "Mana Regen", 34 => "HealShield",
}
STATTYPES = ["", "base ", "bonus "]

def getStatDisplay(stat, type)
  t = STATTYPES[type]
  t = { 13 => "current ", 12 => "maximum " }[stat] if [12, 13].include?(t) && type == 0
  disp = STATICONS[stat]
  return t + "%i:scale#{disp}%"
end

def createSubClass(apiName, v)
  if v.is_a?(Hash)
    t = v["~class"]
    t = t[1...].upcase if t.start_with?("0x")
    klazz = Object.const_get(t)
    v = klazz.new(apiName, v)
  end
  if v.is_a?(Array)
    return v.map { |f| createSubClass(apiName, f) }
  end
  return v
end

class Object
  alias __iset instance_variable_set unless method_defined?(:__iset)
  def instance_variable_set(name, *args)
    name = name[1...] if name.is_a?(String) && name.start_with?("0x")
    name = "@" + name[2...] if name.is_a?(String) && name.start_with?("@0x")
    name = name.gsub(" ", "_") if name.is_a?(String)
    __iset(name, *args)
  end
end

def setTitleFont(bitmap)
  bitmap = bitmap.bitmap if !bitmap.is_a?(Bitmap)
  bitmap.font.name = "Gill Sans MT Pro"
  bitmap.font.size = 28
end

def highlightTextPos(bitmap, chars, highlight, color = TooltipBase::SEARCHCOLOR)
  return if highlight.nil?

  unformatted = chars.map { |c|
    next c[0].downcase unless c[5]
    icon = c[5].dup.downcase.split("/")[-1]
    icon.gsub!("scale", "")
    icon.gsub!("active", "")
    icon.gsub!("mini", "")
    next VALID_IMAGE_STRINGS.include?(icon) ? icon : c[0].downcase
  }

  locs = []

  startpos = 0
  i = 0
  highlightLen = highlight.length
  str = ""
  image = false
  while i < unformatted.length
    str += unformatted[i]
    image = true if unformatted[i].length > 1

    if str.length >= highlightLen
      inc = 1
      if str == highlight || (image && str.start_with?(highlight))
        inc = highlightLen

        locs.push([startpos, i])
      end

      str = ""
      startpos += inc
      i = startpos
      image = false
    else
      i += 1
    end
  end

  locs.each { |loc|
    s, e = loc
    x = chars[s][1]
    y = chars[s][2]
    height = chars[s][4]
    width = chars[e][1] + chars[e][3] - x

    bitmap.fill_rect(x, y, width, height, TooltipBase::SEARCHCOLOR)
  }
end
