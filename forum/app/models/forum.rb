class Forum < ActiveRecord::Base

  self.table_name         = 'fms_forums'
  attr_accessible         :name, :description, :published

  extend FriendlyId
  friendly_id             :name, use: :slugged
  resourcify

  include RankedModel
  ranks                   :row_order
  
  belongs_to              :forum_site
  has_many                :forum_topics, :order => "sticky desc, last_updated_at desc", :dependent => :delete_all

  # this is used to see if a forum is "fresh"... we can't use topics because it puts
  # stickies first even if they are not the most recently modified
  has_many                :recent_topics, :class_name => 'ForumTopic', :include => [:user],
                              :order => "last_updated_at DESC"
  has_one                 :recent_topic,  :class_name => 'ForumTopic', 
                              :order => "last_updated_at DESC"

  default_scope           { where(account_id: Account.current.id).order(:row_order) }
  scope :published,       where(:published => true)

  validates_presence_of   :name

  #------------------------------------------------------------------------------
  # def to_param
  #   permalink
  # end

  #------------------------------------------------------------------------------
  def monitored_topics(user)
    #self.forum_topics.joins(:monitorships).where(:monitorships => {:user_id => user, :active => true})
    self.forum_topics.joins(:monitorships).where(:monitorships => {:user_id => user})
  end

  #------------------------------------------------------------------------------
  def to_s
    name
  end

end
