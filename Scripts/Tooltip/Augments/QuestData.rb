class QuestData
  attr_accessor :apiName
  attr_accessor :TooltipOverride
  attr_accessor :QuestBreakpoints
  attr_accessor :icon

  def initialize(j)
    @apiName = j["apiName"]
    @TooltipOverride = j["TooltipOverride"]
    @QuestBreakpoints = j["QuestBreakpoints"].map { |qb| QuestBreakpoints.new(qb) }
    @icon = j["icon"]
  end
end

class QuestBreakpoints
  attr_accessor :QuestRequirement
  attr_accessor :QuestDesc

  def initialize(j)
    @QuestRequirement = j["QuestRequirement"]
    @QuestDesc = j["QuestDesc"]
  end
end
