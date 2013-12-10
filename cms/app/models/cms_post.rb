class CmsPost < ActiveRecord::Base

  attr_accessible         :slug, :published_on, :title, :content, :summary, :image, :comments_allowed
  
  # --- globalize (don't use versioning: true, translations erased when updating regular model data.  Maybe fixed in github version)
  translates              :title, :summary, :content, :fallbacks_for_empty_translations => true #, :versioning => true
  globalize_accessors     :locales => DmCore::Language.language_array
    
  extend FriendlyId
  friendly_id             :title_slug, use: :slugged

  acts_as_commentable
  
  belongs_to              :cms_blog
  belongs_to              :account
  
  default_scope           { where(account_id: Account.current.id) }
  scope                   :published, lambda { where("published_on <= ?", Time.now ) }
  
  self.per_page = 10

  # --- validations
  validates_presence_of     :slug
  validates_uniqueness_of   :slug, case_sensitive: false
  # validates_uniqueness_of :slug, :scope => :account_id
  
  #------------------------------------------------------------------------------
  def is_published?
    published_on <= Time.now
  end
  
  # Allow comments if also enabled in the blog
  #------------------------------------------------------------------------------
  def comments_allowed?
    cms_blog.comments_allowed? && comments_allowed
  end
  
  # regenerate slug if it's blank
  #------------------------------------------------------------------------------
  def should_generate_new_friendly_id?
    self.slug.blank?
  end

  # Base the slug on the default locale
  #------------------------------------------------------------------------------
  def title_slug
    send("title_#{Account.current.preferred_default_locale}")
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
