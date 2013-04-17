class ForumSite < ActiveRecord::Base
  class UndefinedError < StandardError; end

  set_table_name            'fms_forum_sites'

  attr_accessible           :enabled, :description, :tagline

  has_many :forums,         :conditions => {:state => 'public'}
  has_many :all_forums,     :class_name => 'Forum'
  has_many :forum_topics,   :through => :forums
  has_many :forum_comments, :through => :forums

  default_scope             { where(account_id: Account.current.id) }

  attr_readonly             :comments_count, :forum_topics_count, :users_online


  # There is only one forum site per account
  #------------------------------------------------------------------------------
  def self.site
    ForumSite.first
  end
  
  #------------------------------------------------------------------------------
  def ordered_forums
    forums.ordered
  end

end
