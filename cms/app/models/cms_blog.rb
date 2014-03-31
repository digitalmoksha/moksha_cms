class CmsBlog < ActiveRecord::Base
  include DmCore::Concerns::PublicPrivate

  # --- globalize
  translates                :title, :fallbacks_for_empty_translations => true
  globalize_accessors       :locales => DmCore::Language.language_array
    
  # --- FriendlyId
  extend FriendlyId
  include DmCore::Concerns::FriendlyId

  resourcify

  include RankedModel
  ranks                     :row_order, :with_same => :account_id

  default_scope             { where(account_id: Account.current.id).order(:row_order) }
  scope                     :published, -> { where(:published => true) }
  
  has_many                  :posts, -> { order('published_on DESC') }, :class_name => 'CmsPost', :dependent => :destroy
  belongs_to                :account

  preference                :show_social_buttons,  :boolean, :default => false
  preference                :header_accent_color,  :string

  validates                 :title, presence_default_locale: true

  #------------------------------------------------------------------------------
  def model_slug
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
