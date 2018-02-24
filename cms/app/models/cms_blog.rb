class CmsBlog < ApplicationRecord
  include DmCore::Concerns::PublicPrivate

  # --- globalize
  translates                :title, fallbacks_for_empty_translations: true
  globalize_accessors       locales: I18n.available_locales

  # --- FriendlyId
  extend FriendlyId
  include DmCore::Concerns::FriendlyId

  acts_as_followable
  acts_as_taggable

  resourcify

  include RankedModel
  ranks                     :row_order, with_same: :account_id

  default_scope             { where(account_id: Account.current.id).order(:row_order) }
  scope                     :published, -> { where(published: true) }

  has_many                  :posts, -> { order('published_on DESC') }, class_name: 'CmsPost', dependent: :destroy
  belongs_to                :account
  belongs_to                :owner, polymorphic: true

  preference                :show_social_buttons,  :boolean, default: false
  preference                :header_accent_color,  :string

  validates                 :title, presence_default_locale: true
  validates_uniqueness_of   :slug, scope: :account_id
  validates_length_of       :slug, maximum: 255
  validates_length_of       :header_image, maximum: 255
  validates_length_of       :image_email_header, maximum: 255
  I18n.available_locales.each do |locale|
    validates_length_of :"title_#{locale}", maximum: 255
  end

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

  # Return the header image, or a default if not specified
  #------------------------------------------------------------------------------
  def header_image(default = nil)
    attributes['header_image'] || default
  end

  #------------------------------------------------------------------------------
  def header_accent_color(default = '')
    preferred_header_accent_color || default
  end

  # return a list of tags for all Blog post objects
  #------------------------------------------------------------------------------
  def self.tag_list_all
    CmsBlog.tag_counts_on(:tags).map(&:name).sort
  end

  # Grab a list of the recent posts.  Can pull from all blogs or a specific
  # one.
  #------------------------------------------------------------------------------
  def self.recent_posts(options = { user: nil, limit: 5, blog: nil })
    query_blogs = if options[:blog].nil? # get all available to user
                    CmsBlog.available_to_user(options[:user]).map(&:id)
                  else
                    CmsBlog.friendly.find(options[:blog])
                  end
    CmsPost.where(cms_blog_id: query_blogs).includes(:cms_blog, :translations).published.order('published_on DESC').limit(options[:limit])
  end

  # Send new post notifications to any followers
  # NOTE: Currently, we don't do automated notifications for new blog posts.
  # You must click on the button in the backend to trigger it.  At the moment,
  # we desire that extra level of control.  If we decided to enable this in the
  # future, selecting using the notification_sent_on column, make sure that
  # all current posts are non-nil, so we don't trigger a much of old posts
  # being sent
  #------------------------------------------------------------------------------
  # def self.notify_followers(start_time, end_time = Time.now)
  #   posts = CmsPost.published.includes(:cms_blog).where(cms_blogs: {published: true}).where(notification_sent_on: nil)
  #   posts.each {|post| post.send_notification_emails }
  # end
end
