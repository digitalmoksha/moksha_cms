class Forum < ApplicationRecord
  include DmCore::Concerns::PublicPrivate

  self.table_name = 'fms_forums'

  # --- FriendlyId
  extend FriendlyId
  friendly_id                 :name, use: :scoped, scope: :account_id
  validates_presence_of       :slug
  before_save                 :normalize_slug

  resourcify

  include RankedModel
  ranks                       :row_order, with_same: :forum_category_id

  belongs_to                  :forum_site, optional: true
  belongs_to                  :forum_category, class_name: 'ForumCategory', optional: true
  has_many                    :forum_topics, -> { order('sticky desc, last_updated_at desc') }, dependent: :destroy
  belongs_to                  :owner, polymorphic: true, optional: true

  # this is used to see if a forum is "fresh"... we can't use topics because it puts
  # stickies first even if they are not the most recently modified
  has_many                    :recent_topics, -> { includes(:user).order('last_updated_at DESC') }, class_name: 'ForumTopic'
  has_one                     :recent_topic,  -> { order('last_updated_at DESC') },                 class_name: 'ForumTopic'

  default_scope               { where(account_id: Account.current.id).order(:row_order) }
  scope                       :published, -> { where(published: true) }

  # --- validations
  validates_presence_of       :name

  # If user set slug sepcifically, we need to make sure it's been normalized
  #------------------------------------------------------------------------------
  def normalize_slug
    self.slug = normalize_friendly_id(slug)
  end

  # regenerate slug if it's blank
  #------------------------------------------------------------------------------
  def should_generate_new_friendly_id?
    slug.blank?
  end

  # use babosa gem (to_slug) to allow better handling of multi-language slugs
  #------------------------------------------------------------------------------
  def normalize_friendly_id(text)
    text.to_s.to_slug.normalize.to_s
  end

  #------------------------------------------------------------------------------
  def followed_topics(user)
    user.following.following_by_type('ForumTopic').where(forum_id: id)
  end

  #------------------------------------------------------------------------------
  def to_s
    name
  end
end
