# Wrap core level specific CanCan rules.  Should be included in the main app's
# Ability class.
#------------------------------------------------------------------------------
module DmCore
  module Concerns
    module Ability
      def dm_core_abilities(user)
        if user
          if user.is_admin? || user.has_role?(:manager)
            can :manage, :all
            can :access_admin, :all
          end
        end
      end
    end
  end
end
