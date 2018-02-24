class CmsPost < ApplicationRecord
  # --- globalize (don't use versioning: true, translations erased when updating regular model data.  Maybe fixed in github version)
  translates              :title, :summary, :content, :fallbacks_for_empty_translations => true # , :versioning => true
  globalize_accessors     locales: I18n.available_locales

  # --- FriendlyId
  extend FriendlyId
  include DmCore::Concerns::FriendlyId
  friendly_id             :model_slug, use: :scoped, scope: [:account_id, :cms_blog] # re-define so is scoped to the blog as well

  acts_as_commentable
  acts_as_taggable

  belongs_to              :cms_blog
  belongs_to              :account

  default_scope           { where(account_id: Account.current.id) }
  scope                   :published, -> { where("published_on IS NOT NULL AND published_on <= ?", Time.now) }

  validates               :title, presence_default_locale: true
  validates               :summary, liquid: { :locales => true }, presence_default_locale: true
  validates               :content, liquid: { :locales => true }, presence_default_locale: true
  validates_uniqueness_of :slug, scope: [:account_id, :cms_blog_id]
  validates_length_of     :slug, maximum: 255
  validates_length_of     :featured_image, maximum: 255
  I18n.available_locales.each do |locale|
    validates_length_of :"title_#{locale}", maximum: 255
  end
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

  # return a list of tags for all Blog post objects
  #------------------------------------------------------------------------------
  def self.tag_list_all
    CmsPost.tag_counts_on(:tags).map(&:name).sort
  end

  # Send post notification to any members and followers.  Updates the
  # :notification_sent_on column after emails sent.
  # Use 'sets' to only end up with a unique list of users
  #------------------------------------------------------------------------------
  def send_notification_emails(test_user = nil)
    if test_user
      email = PostNotifyMailer.post_notify(test_user, self, self.account).deliver_now
      return (email ? 1 : 0)
    else
      user_list = cms_blog.member_list(:all).to_set
      cms_blog.user_site_profile_followers.each { |follower| user_list << follower.user }
      async_send_notification_emails(user_list)
      return user_list.size
    end
  end

  #------------------------------------------------------------------------------
  def async_send_notification_emails(user_list)
    success = failed = 0
    Rails.logger.info "=== Sending #{user_list.size} emails for blog post '#{title}'"
    user_list.each do |user|
      email     = PostNotifyMailer.post_notify(user, self, self.account).deliver_later
      success  += 1 if email
      failed   += 1 if email.nil?
    end
    update_attribute(:notification_sent_on, Time.now)
    Rails.logger.info "    Completed sending: successes (#{success}) -- failures (#{failed}) "
  end
end
