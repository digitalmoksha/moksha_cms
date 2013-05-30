class Forum < ActiveRecord::Base
  include DmCore::Concerns::PublicPrivate

  self.table_name             = 'fms_forums'
  attr_accessible             :name, :description, :published, :is_public, :requires_login

  extend FriendlyId
  friendly_id                 :name, use: :slugged
  resourcify

  include RankedModel
  ranks                       :row_order, :with_same => :forum_category_id
  
  belongs_to                  :forum_site
  belongs_to                  :forum_category, :class_name => 'ForumCategory'
  has_many                    :forum_topics, :order => "sticky desc, last_updated_at desc", :dependent => :destroy

  # this is used to see if a forum is "fresh"... we can't use topics because it puts
  # stickies first even if they are not the most recently modified
  has_many                    :recent_topics, :class_name => 'ForumTopic', :include => [:user],
                                :order => "last_updated_at DESC"
  has_one                     :recent_topic,  :class_name => 'ForumTopic', 
                                :order => "last_updated_at DESC"

  default_scope               { where(account_id: Account.current.id).order(:row_order) }
  scope :published,           where(:published => true)

  validates_presence_of       :name

  #------------------------------------------------------------------------------
  def monitored_topics(user)
    self.forum_topics.joins(:monitorships).where(:fms_monitorships => {:user_id => user, :active => true})
  end

  #------------------------------------------------------------------------------
  def to_s
    name
  end
  
  # Can this forum be replied to by user.  Covers whether a topic can be created.
  #------------------------------------------------------------------------------
  def can_be_replied_by?(attempting_user)
    if attempting_user
      self.published? && (self.is_public? || self.is_protected? || (self.member?(attempting_user)))
    else
      false
    end
  end
  
end
