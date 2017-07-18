module DmSpree
  module Concerns
    module Ability
      def dm_spree_abilities(user)
        if user
          # TODO current feeling is this is not needed - use the event manager permissions
        end
      end

      ::Ability.register_abilities(:dm_spree_abilities)
      
    end
  end
end
