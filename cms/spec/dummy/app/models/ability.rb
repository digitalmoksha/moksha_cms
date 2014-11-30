# Application's CanCan ability class, include all gem abilities
#------------------------------------------------------------------------------
class Ability
  include CanCan::Ability
  include DmCore::Concerns::Ability
  include DmCms::Concerns::Ability
  
  def initialize(user)
    dm_cms_abilities(user)            if respond_to? :dm_cms_abilities
    dm_core_abilities(user)           if respond_to? :dm_core_abilities
  end
end
