# Extends the User model with hooks for the Event engine
#------------------------------------------------------------------------------
module DmEvent
  module Concerns
    module UserProfile
      extend ActiveSupport::Concern

      included do

        has_many   :registrations
        
        # has_many :forum_comments, {:as => :commentable, :dependent => :delete_all}
        # has_many :forum_topics, :order => "#{ForumTopic.table_name}.created_at desc"
        # 
        # has_many :monitorships, :dependent => :delete_all
        # has_many :monitored_topics, :through => :monitorships, :source => :forum_topic, :conditions => {"#{Monitorship.table_name}.active" => true}

      end

      #------------------------------------------------------------------------------
      module ClassMethods
      end

    end
  end
end
