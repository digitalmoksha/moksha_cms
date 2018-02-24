# Application's CanCan ability class. Engines will include their ability classes
#------------------------------------------------------------------------------
class Ability
  include CanCan::Ability
  include DmCore::Concerns::Ability

  @@registered_abilities = []

  #------------------------------------------------------------------------------
  def initialize(user)
    @user_roles = user.roles.all if user
    @@registered_abilities.each { |method| self.send method, user }

    dm_core_abilities(user)
  end

  # allows an engine to register it's ability method
  #------------------------------------------------------------------------------
  def self.register_abilities(method_name)
    @@registered_abilities << method_name
  end
end
