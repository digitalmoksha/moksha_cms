class CmsPost < ActiveRecord::Base

  attr_accessible         :slug, :published_on, :title, :content, :summary, :image
  
  # --- globalize
  translates              :title, :summary, :content, :fallbacks_for_empty_translations => true, :versioning => true
  globalize_accessors     :locals => DmCore::Language.language_array
    
  extend FriendlyId
  friendly_id             :title_slug, use: :slugged

  belongs_to              :cms_blog
  
  default_scope           { where(account_id: Account.current.id) }
  scope                   :published, lambda { where("published_on <= ?", Time.now ) }
  
  # --- validations
  # validates_length_of     :slug, :maximum => 50
  # validates_presence_of   :slug
  # validates_uniqueness_of :slug, :scope => :account_id
  
  #------------------------------------------------------------------------------
  def is_published?
    published_on <= Time.now
  end
  
  # Base the slug on the default locale
  #------------------------------------------------------------------------------
  def title_slug
    send("title_#{Account.current.preferred_default_locale}")
  end

  #------------------------------------------------------------------------------
  def display_summary
    summary || content.smart_truncate(:words => 50)
  end
end
