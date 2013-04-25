# Wrap core level specific CanCan rules.  Should be included in the main app's
# Ability class.
#------------------------------------------------------------------------------
module DmCore
  module Concerns
    module Ability
      def dm_core_abilities(user)
        if user
          can :manage, :all if user.has_role? :admin
        end
      end
    end
  end
end