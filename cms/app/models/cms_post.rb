class CmsPost < ActiveRecord::Base

  # --- globalize (don't use versioning: true, translations erased when updating regular model data.  Maybe fixed in github version)
  translates              :title, :summary, :content, :fallbacks_for_empty_translations => true #, :versioning => true
  globalize_accessors     :locales => DmCore::Language.language_array
    
  # --- FriendlyId
  extend FriendlyId
  include DmCore::Concerns::FriendlyId

  acts_as_commentable
  
  belongs_to              :cms_blog
  belongs_to              :account
  
  default_scope           { where(account_id: Account.current.id) }
  scope                   :published, -> { where("published_on IS NOT NULL AND published_on <= ?", Time.now ) }
  
  validates               :title, presence_default_locale: true
  validates               :summary, liquid: { :locales => true }, presence_default_locale: true
  validates               :content, liquid: { :locales => true }, presence_default_locale: true
  
  self.per_page = 10
  
  # Base the slug on the default locale
  #------------------------------------------------------------------------------
  def model_slug
    send("title_#{Account.current.preferred_default_locale}")
  end

  #------------------------------------------------------------------------------
  def is_published?
    !published_on.nil? && published_on <= Time.now
  end
  
  # Allow comments if also enabled in the blog
  #------------------------------------------------------------------------------
  def comments_allowed?
    cms_blog.comments_allowed? && comments_allowed
  end
  
  # Send post notification to any members and followers.  Updates the 
  # :notification_sent_on column after emails sent.
  # Use 'sets' to only end up with a unique list of users
  #------------------------------------------------------------------------------
  def send_notification_emails(test_user = nil)
    success = failed = 0
    if test_user
      user_list = [test_user]
    else
      user_list = cms_blog.member_list(:all).to_set
      cms_blog.followers.each {|follower| user_list << follower.user}
    end
    user_list.each do |user|
      email     = PostNotifyMailer.post_notify(user, self).deliver
      success  += 1 if email
      failed   += 1 if email.nil?
    end

    update_attribute(:notification_sent_on, Time.now) unless test_user
    return {success: success, failed: failed}
  end

end
