# Application's CanCan ability class, include all gem abilities
#------------------------------------------------------------------------------
class Ability
  include CanCan::Ability
  include DmCore::Concerns::Ability
  include DmKnowledge::Concerns::Ability
  
  def initialize(user)
    dm_knowledge_abilities(user)      if respond_to? :dm_knowlege_abilities
    dm_core_abilities(user)           if respond_to? :dm_core_abilities
  end
end
