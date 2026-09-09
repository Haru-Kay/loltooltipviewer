class ChampionData
  attr_accessor :name, :tags, :arTypes, :icon, :augmentPool
  def initialize(name, data)
    @name = name
    @tags = data["tags"]
    @arTypes = data["arTypes"]
    @icon = data["icon"]
    compileAugmentPool(data["augments"])
  end

  def hasMana?
    @arTypes.include?(0)
  end

  def hasTrait?(*args)
    args.flatten.any? {|t| @tags.include?(t) }
  end

  def hasDash?
    self.hasTrait?(["PositiveEffect_MoveBlock", "Trait_PlayerSelectedDashDirection"])
  end

  def hasCC?
    self.hasTrait?([
      "Trait_ImmobilizingCCSpell",
      "Trait_ImmobilizingCCAbility",
      "Trait_SwapsIntoImmobilizingCCAbility"
    ])
  end

  def hasUlt?
    self.hasTrait?([
      "Trait_Ultimate",
      "Trait_UltimateReactivation"
    ])
  end

  def hasSelfHeal?
    self.hasTrait?("Trait_SelfHeal")
  end

  def hasShield?
    self.hasTrait?("Trait_Shield")
  end

  def hasHeal?
    self.hasTrait?("Trait_ActiveHeal")
  end

  def compileAugmentPool(data)
    @augmentPool = {
      AugmentRarities::Silver => {}, AugmentRarities::Gold => {}, AugmentRarities::Prismatic => {}
    }
    #puts @name
    data.each { |group, weight|
      augmentGroup = $cache.groups[group]
        #puts group
      augmentGroup.augments.each { |a|
        next if $cache.groups["mana"].include?(a) && !self.hasMana?
        next if $cache.groups["DashAugments"].include?(a) && !self.hasDash?
        next if $cache.groups["CCAugments"].include?(a) && !self.hasCC?
        next if $cache.groups["RequiresUltimateAugments"].include?(a) && !self.hasUlt?
        next if $cache.groups["SelfHealingAugments"].include?(a) && !self.hasSelfHeal?
        next if $cache.groups["ShieldAugmentsGeneral"].include?(a) && !self.hasShield?
        next if $cache.groups["SupportAugmentsHealing"].include?(a) && !self.hasHeal?
        next if $cache.groups["SupportAugmentsHealing2"].include?(a) && !self.hasHeal?
        next if a == "Terraind" && !self.hasTrait?("Trait_CreateTerrain")
        next if a == "Bonk" && !(self.hasTrait?("PositiveEffect_EmpowerAttack") && self.hasTrait?("Trait_Strike")) # best assumption
        next if a == "DontChangeTheChannel" && !self.hasTrait?("Trait_ChannelSpell")
        next if a == "Ability_SelfAOE_DoubleCast" && !self.hasTrait?("Trait_AoE")
        next if a == "ARAM_Minionmancer" && !self.hasTrait?("Trait_Pet") && !["Elise", "Zyra"].include?(@name) # death
        next if ["Overkill", "ItsGoTime", "LittleExtraHelp"].include?(a) && !self.hasTrait?("Trait_AttackBuff_Duration")
        next if a == "ARAM_SpinToWin" && ![
          "Katarina", "Draven", "Garen", "Akshan", "Ambessa", "Rammus", "Rek'Sai",
          "Kayn", "Hecarim", "Darius", "Lillia", "Renekton"
        ].include?(@name) # also death. these are all script side and can't be determined without a Rioter telling us.
        next if [
          "VoidDash", "DoubleStrike", "Quest_Sneakerhead"
        ].include?(a) # disabled via script rather than api

        augment = $cache.augments[a]
        next if !augment
        next if augment.disabled

        rarity = ["Silver", "Gold", "Prismatic"].index(augment.rarity)
        @augmentPool[rarity][a] ||= 0
        @augmentPool[rarity][a] += weight
      }
    }
  end
end
