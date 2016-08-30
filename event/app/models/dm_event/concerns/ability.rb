# Wrap event specific CanCan rules.  Should be included in the main app's
# Ability class.
# NOTE:  When checking abilities, don't check for Class level abilities,
# unless you don't care about the instance level.  For example, don't
# use both styles
#   can? :moderate, Workshop
#   can? :moderate, @workshop
# In this case, if you need to check the class level, then use specific
#    current_user.has_role? :moderator, Workshop
#------------------------------------------------------------------------------
""
module DmEvent
  module Concerns
    module Ability
      def dm_event_abilities(user)
        if user
          if user.has_role?(:event_manager)
            can :manage_events, :all
            can :manage_event_finances, :all
            can :access_admin, :all
          else
            workshop_ids = Workshop.published.with_role(:manage_event, user).map(&:id)
            unless workshop_ids.empty?
              can :manage_events, Workshop, :id => workshop_ids
              can :manage_event_finances, Workshop, :id => Workshop.published.with_role(:manage_event_finance, user).map(&:id)
              can :access_admin, :all
            end
          end

        end
      end
    end
  end
end

#------------------------------------------------------------------------------
# The abilities get basically compiled.  So if you use
#
#    can :moderate, Workshop, :id => Workshop.with_role(:moderator, user).map(&:id)
#
# this will execute the Workshop.with_role query once during Ability.new.  However
#
#    can :moderate, Workshop do |workshop|
#      user.has_role? :moderator, workshop
#    end
#
# this will execute the has_role? block on each call to can?
