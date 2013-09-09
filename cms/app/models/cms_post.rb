class CmsPost < ActiveRecord::Base

  attr_accessible         :slug, :published_on, :title, :content, :summary, :image, :comments_allowed
  
  # --- globalize (don't use versioning: true, translations erased when updating regular model data.  Maybe fixed in github version)
  translates              :title, :summary, :content, :fallbacks_for_empty_translations => true #, :versioning => true
  globalize_accessors     :locals => DmCore::Language.language_array
    
  extend FriendlyId
  friendly_id             :title_slug, use: :slugged

  acts_as_commentable
  
  belongs_to              :cms_blog
  belongs_to              :account
  
  default_scope           { where(account_id: Account.current.id) }
  scope                   :published, lambda { where("published_on <= ?", Time.now ) }
  
  self.per_page = 10

  # --- validations
  # validates_length_of     :slug, :maximum => 50
  # validates_presence_of   :slug
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
  
  # Base the slug on the default locale
  #------------------------------------------------------------------------------
  def title_slug
    send("title_#{Account.current.preferred_default_locale}")
  end

  #------------------------------------------------------------------------------
  def display_summary
    summary || (content.blank? ? '' : content.smart_truncate(:words => 50))
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
