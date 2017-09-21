# toggles whether a user is following a specific object, like a blog or forum
#------------------------------------------------------------------------------
module DmCore
  class ToggleFollowerService
    include DmCore::ServiceSupport

    #------------------------------------------------------------------------------
    def initialize(user, object_to_follow)
      @user, @object_to_follow = user, object_to_follow
    end

    # returns true if the item is now being followed, else false
    #------------------------------------------------------------------------------
    def call
      following = @user.following.follows?(@object_to_follow)
      following ? @user.following.unfollow(@object_to_follow) : @user.following.follow(@object_to_follow)
      return !following
    end
  end
end
