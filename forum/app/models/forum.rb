class Forum < ActiveRecord::Base

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
  scope :all_public_forums,   where(:is_public => true)
  scope :public_forums,       where(:is_public => true, :requires_login => false)
  scope :protected_forums,    where(:is_public => true, :requires_login => true)
  scope :private_forums,      where(:is_public => false)

  validates_presence_of       :name

  # Get list of available forums for user
  #------------------------------------------------------------------------------
  def self.available_forums(user)
    if user.nil?
      #--- not logged in, only public forums
      forums = Forum.public_forums.published
    elsif user.is_admin?
      forums = Forum.all
    else
      #--- all public/protected, as well as private that they are a member
      forums  = Forum.all_public_forums.published
      forums += Forum.private_forums.published.with_role(:member, user)
      return forums
    end
  end

  #------------------------------------------------------------------------------
  def monitored_topics(user)
    self.forum_topics.joins(:monitorships).where(:fms_monitorships => {:user_id => user, :active => true})
  end

  #------------------------------------------------------------------------------
  def to_s
    name
  end
  
  # check if the forum is public (does not require login)
  #------------------------------------------------------------------------------
  def is_public?
    is_public == true && requires_login == false
  end
  
  # check if the forum is protected (public and requires login)
  #------------------------------------------------------------------------------
  def is_protected?
    is_public == true && requires_login == true
  end
  
  # check if the forum is public (does not require login)
  #------------------------------------------------------------------------------
  def is_private?
    is_public == false
  end
  
  # Is the user a member of this forum?
  #------------------------------------------------------------------------------
  def member?(user)
    user.has_role? :member, self
  end
  
  # Can this forum be read by a user
  #------------------------------------------------------------------------------
  def can_be_read_by?(attempting_user)
    if attempting_user
      self.published? && (self.is_public? || self.is_protected? || (self.member?(attempting_user) || attempting_user.is_admin?))
    else
      self.published? && self.is_public?
    end
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
