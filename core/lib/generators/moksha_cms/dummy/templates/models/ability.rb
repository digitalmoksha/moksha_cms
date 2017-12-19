# Application's CanCan ability class, include all gem abilities
#------------------------------------------------------------------------------
class Ability
  include CanCan::Ability
  include DmCore::Concerns::Ability

  def initialize(user)
    dm_core_abilities(user)           if respond_to? :dm_core_abilities
  end
end
