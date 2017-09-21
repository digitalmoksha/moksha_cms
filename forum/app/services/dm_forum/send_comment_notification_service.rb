module DmForum
  class SendCommentNotificationService
    include DmCore::ServiceSupport

    #------------------------------------------------------------------------------
    def initialize(comment)
      @comment = comment
    end

    #------------------------------------------------------------------------------
    def call
      forum_topic = @comment.commentable
      forum_topic.user_site_profile_followers.each do |follower|
        email = ForumNotificationMailer.follower_notification(follower.user, forum_topic, [@comment]).deliver_later
      end
    end
  end
end
