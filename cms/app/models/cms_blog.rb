class CmsBlog < ActiveRecord::Base
  include DmCore::Concerns::PublicPrivate

  attr_accessible         :slug, :published, :requires_login, :comments_allowed
  
  # --- globalize
  translates              :title, :fallbacks_for_empty_translations => true
  globalize_accessors     :locals => DmCore::Language.language_array
    
  extend FriendlyId
  friendly_id               :title_slug, use: :slugged
  resourcify

  include RankedModel
  ranks                     :row_order, :with_same => :account_id

  default_scope             { where(account_id: Account.current.id).order(:row_order) }
  scope :published,         where(:published => true)
  
  has_many                  :posts, :class_name => 'CmsPost', :order => "published_on DESC", :dependent => :destroy
  belongs_to                :account

  # --- validations
  # validates_length_of     :slug, :maximum => 50
  # validates_presence_of   :slug
  # validates_uniqueness_of :slug, :scope => :account_id
  
  #------------------------------------------------------------------------------
  def is_published?
    published
  end
  
  #------------------------------------------------------------------------------
  def title_slug
    send("title_#{Account.current.preferred_default_locale}")
  end

  # Are any of the blogs readable by this user? One positive is all need...
  #------------------------------------------------------------------------------
  def any_readable_blogs?(user)
    CmsBlog.all.any? { |b| b.can_be_read_by?(user) }
  end

end
