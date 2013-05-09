# Extends the User model with hooks for the Event engine
#------------------------------------------------------------------------------
module DmEvent
  module Concerns
    module User
      extend ActiveSupport::Concern

      # 'included do' causes the included code to be evaluated in the
      # conext where it is included (post.rb), rather than be 
      # executed in the module's context (blorgh/concerns/models/post).
      #------------------------------------------------------------------------------
      included do

        # has_many :forum_comments, {:as => :commentable, :dependent => :delete_all}
        # has_many :forum_topics, :order => "#{ForumTopic.table_name}.created_at desc"
        # 
        # has_many :monitorships, :dependent => :delete_all
        # has_many :monitored_topics, :through => :monitorships, :source => :forum_topic, :conditions => {"#{Monitorship.table_name}.active" => true}

        #------------------------------------------------------------------------------
        # def available_forums
        #   @available_forums ||= site.ordered_forums - forums
        # end
      end

      #------------------------------------------------------------------------------
      module ClassMethods
      end

    end
  end
end
