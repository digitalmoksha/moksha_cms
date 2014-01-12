class CmsBlog < ActiveRecord::Base
  include DmCore::Concerns::PublicPrivate

  attr_accessible           :slug, :published, :requires_login, :comments_allowed, :image
  
  # --- globalize
  translates                :title, :fallbacks_for_empty_translations => true
  globalize_accessors       :locales => DmCore::Language.language_array
    
  # --- FriendlyId
  extend FriendlyId
  friendly_id               :title_slug, use: :scoped, scope: :account_id
  validates_presence_of     :slug
  before_save               :normalize_slug

  resourcify

  include RankedModel
  ranks                     :row_order, :with_same => :account_id

  default_scope             { where(account_id: Account.current.id).order(:row_order) }
  scope :published,         where(:published => true)
  
  has_many                  :posts, :class_name => 'CmsPost', :order => "published_on DESC", :dependent => :destroy
  belongs_to                :account

  preference                :show_social_buttons,  :boolean, :default => false
  attr_accessible           :preferred_show_social_buttons

  # regenerate slug if it's blank
  #------------------------------------------------------------------------------
  def should_generate_new_friendly_id?
    self.slug.blank?
  end

  # If user set slug sepcifically, we need to make sure it's been normalized
  #------------------------------------------------------------------------------
  def normalize_slug
    self.slug = normalize_friendly_id(self.slug)
  end
  
  # use babosa gem (to_slug) to allow better handling of multi-language slugs
  #------------------------------------------------------------------------------
  def normalize_friendly_id(text)
    text.to_s.to_slug.normalize.to_s
  end
  
  #------------------------------------------------------------------------------
  def title_slug
    send("title_#{Account.current.preferred_default_locale}")
  end

  #------------------------------------------------------------------------------
  def is_published?
    published
  end
  
  #------------------------------------------------------------------------------
  def show_social_buttons?
    preferred_show_social_buttons? && !is_private?
  end
  
  # Are any of the blogs readable by this user? One positive is all need...
  #------------------------------------------------------------------------------
  def any_readable_blogs?(user)
    CmsBlog.all.any? { |b| b.can_be_read_by?(user) }
  end

end
