# Wrap forum specific CanCan rules.  Should be included in the main app's
# Ability class.
# NOTE:  When checking abilities, don't check for Class level abilities,
# unless you don't care about the instance level.  For example, don't
# use both styles
#   can? :moderate, Forum
#   can? :moderate, @forum
# In this case, if you need to check the class level, then use specific
#    current_user.has_role? :moderator, Forum
#------------------------------------------------------------------------------

module DmForum
  module Concerns
    module Ability
      def dm_forum_abilities(user)
        if user
          #--- Admin
          if user.has_role?(:forum_manager)
            can :manage_forums, :all
            can :access_admin, :all
          end

          #--- Forum
          can(:read, Forum)   { |forum| forum.can_be_read_by?(user) }
          can(:reply, Forum)  { |forum| forum.can_be_replied_by?(user) }
          can :moderate, Forum, :id => Forum.published.with_role(:moderator, user).map(&:id)

          #--- Comment
          can :edit, ForumComment, :user_id => user.id
        else
          #--- can only read/see public forums when not logged in
          can(:read, Forum)   { |forum| forum.can_be_read_by?(user) }
        end
      end

      ::Ability.register_abilities(:dm_forum_abilities)
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
