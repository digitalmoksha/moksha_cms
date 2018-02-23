# Wrap lms specific CanCan rules.  Should be included in the main app's
# Ability class.
# NOTE:  When checking abilities, don't check for Class level abilities,
# unless you don't care about the instance level.  For example, don't
# use both styles
#   can? :moderate, Forum
#   can? :moderate, @forum
# In this case, if you need to check the class level, then use specific
#    current_user.has_role? :moderator, Forum
#------------------------------------------------------------------------------

module DmLms
  module Concerns
    module Ability
      def dm_lms_abilities(user)
        # Admin
        if user && user.has_role?(:course_manager)
          can :manage_courses, :all
          can :access_admin, :all
        end

        if user && user.try('subscribed_content_allowed?') # from the dm_subscription gem
          # a subscriber can view any published course
          can :read, Course, published: true
        else
          # can only read published course that doesn't require a subscription
          # can :read, Course, published: true, require_subscription: false
          can(:read, Course)  { |course| course.can_be_read_by?(user) }
        end
      end

      ::Ability.register_abilities(:dm_lms_abilities)
    end
  end
end

#------------------------------------------------------------------------------
# The abilities get basically compiled.  So if you use
#
#    can :moderate, Forum, :id => Forum.with_role(:moderator, user).map(&:id)
#
# this will execute the Forum.with_role query once during Ability.new.  However
#
#    can :moderate, Forum do |forum|
#      user.has_role? :moderator, forum
#    end
#
# this will execute the has_role? block on each call to can?
