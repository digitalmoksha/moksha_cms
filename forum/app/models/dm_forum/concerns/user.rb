# Extends the User model with hooks for the Forum
#------------------------------------------------------------------------------
module DmForum
  module Concerns
    module User
      extend ActiveSupport::Concern

      # 'included do' causes the included code to be evaluated in the
      # conext where it is included (post.rb), rather than be
      # executed in the module's context (blorgh/concerns/models/post).
      #------------------------------------------------------------------------------
      included do
        has_many :forum_comments, {:as => :commentable, :dependent => :delete_all}
        has_many :forum_topics, -> { order("#{ForumTopic.table_name}.created_at desc") }

        #------------------------------------------------------------------------------
        def available_forums
          @available_forums ||= site.ordered_forums - forums
        end
      end

      #------------------------------------------------------------------------------
      module ClassMethods
      end

    end
  end
end

# {todo} non-working attempts to include this automatically if the forum engine is being used,
# so that it doesn't have to be added to the application's user.rb file by hand
#------------------------------------------------------------------------------
# class User
#   include DmForum::Concerns::User
# end
# User.send :include, DmForum::Concerns::User
