class Forum < ActiveRecord::Base
  include DmCore::Concerns::PublicPrivate

  self.table_name             = 'fms_forums'
  attr_accessible             :slug, :name, :description, :published, :is_public, :requires_login

  # --- FriendlyId
  extend FriendlyId
  friendly_id                 :name, use: :scoped, scope: :account_id
  validates_presence_of       :slug
  before_save                 :normalize_slug

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

  # --- validations
  validates_presence_of       :name

  # If user set slug sepcifically, we need to make sure it's been normalized
  #------------------------------------------------------------------------------
  def normalize_slug
    self.slug = normalize_friendly_id(self.slug)
  end
  
  # regenerate slug if it's blank
  #------------------------------------------------------------------------------
  def should_generate_new_friendly_id?
    self.slug.blank?
  end

  # use babosa gem (to_slug) to allow better handling of multi-language slugs
  #------------------------------------------------------------------------------
  def normalize_friendly_id(text)
    text.to_s.to_slug.normalize.to_s
  end
  
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
