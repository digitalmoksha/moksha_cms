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
module DmEvent
  module Concerns
    module Ability
      def dm_event_abilities(user)
        if user
          # an `event_manager` gets access to all workshops, registration, and finances.
          if user.has_role?(:event_manager)
            can :manage_events, :all
            can :manage_event_registrations, :all
            can :manage_event_finances, :all
            can :access_event_section, :all
            can :list_events, :all
            # can :access_media_library, :all
            can :access_admin, :all
          elsif user.has_role?(:event_manager_alacarte)
            # allowed to access the backend event section
            can :access_event_section, :all
            can :access_admin, :all

            # can edit a workshop, including workshop prices and email templates
            # (does not include access to registrations or finances)
            manage_event_ids = @user_roles.select {|r| r.name == 'manage_event' && r.resource_type == 'Workshop'}.map(&:resource_id)
            can :manage_events, Workshop, id: manage_event_ids
            # can(:access_media_library, :all) unless manage_event_ids.empty?
            
            # can see and manage a workshops registrations
            manage_event_registration_ids = @user_roles.select {|r| r.name == 'manage_event_registration' && r.resource_type == 'Workshop'}.map(&:resource_id)
            can :manage_event_registrations, Workshop, id: manage_event_registration_ids

            # can see and manage a workshops finances
            manage_event_finance_ids = @user_roles.select {|r| r.name == 'manage_event_finance' && r.resource_type == 'Workshop'}.map(&:resource_id)
            can :manage_event_finances, Workshop, id: manage_event_finance_ids
            
            can :list_events, Workshop, id: (manage_event_ids + manage_event_registration_ids + manage_event_finance_ids).uniq
          end

        end
      end

      ::Ability.register_abilities(:dm_event_abilities)
      
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
