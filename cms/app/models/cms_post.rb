class CmsPost < ActiveRecord::Base

  attr_accessible         :slug, :published_on, :title, :content, :summary, :image, :comments_allowed
  
  # --- globalize (don't use versioning: true, translations erased when updating regular model data.  Maybe fixed in github version)
  translates              :title, :summary, :content, :fallbacks_for_empty_translations => true #, :versioning => true
  globalize_accessors     :locales => DmCore::Language.language_array
    
  # --- FriendlyId
  extend FriendlyId
  friendly_id             :title_slug, use: :scoped, scope: :account_id
  validates_presence_of   :slug
  before_save             :normalize_slug

  acts_as_commentable
  
  belongs_to              :cms_blog
  belongs_to              :account
  
  default_scope           { where(account_id: Account.current.id) }
  scope                   :published, lambda { where("published_on <= ?", Time.now ) }
  
  self.per_page = 10
  
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
  
  # Base the slug on the default locale
  #------------------------------------------------------------------------------
  def title_slug
    send("title_#{Account.current.preferred_default_locale}")
  end

  #------------------------------------------------------------------------------
  def is_published?
    published_on <= Time.now
  end
  
  # Allow comments if also enabled in the blog
  #------------------------------------------------------------------------------
  def comments_allowed?
    cms_blog.comments_allowed? && comments_allowed
  end
  
  # Send an email for state notification.  if send_email is false, just return 
  # the content of the email
  #------------------------------------------------------------------------------
  def send_notification_emails()
    success = failed = 0
    cms_blog.member_list.each do |user|
      email =  PostNotifyMailer.post_notify(self, user.email).deliver
      success  += 1 if email
      failed   += 1 if email.nil?
    end
    update_attribute(:notification_sent_on, Time.now)
    return {success: success, failed: failed}
  end

end
