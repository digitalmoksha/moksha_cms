class ForumTopic < ApplicationRecord
  self.table_name = 'fms_forum_topics'

  attr_accessor           :body
  attr_readonly           :comments_count, :hits, :forum_posts_count

  # --- FriendlyId
  extend FriendlyId
  include DmCore::Concerns::FriendlyId

  acts_as_followable

  before_validation       :set_default_attributes, on: :create

  after_create            :create_initial_comment
  before_update           :check_for_moved_forum
  after_update            :set_comment_forum_id
  before_destroy          :count_user_comments_for_counter_cache
  after_destroy           :update_cached_forum_and_user_counts

  #--- creator of forum topic
  belongs_to              :user
  belongs_to              :account

  #--- creator of recent comment
  belongs_to              :last_user, class_name: 'User', optional: true

  belongs_to              :forum, counter_cache: true

  #--- forum's site, set by callback
  belongs_to              :forum_site, counter_cache: true

  #--- don't use acts_as_commentable since we're using a specialized ForumComment class
  has_many                :forum_comments, { as: :commentable, dependent: :destroy }
  has_one                 :recent_comment, -> { where(ancestry_depth: 1).order('created_at DESC') }, as: :commentable, class_name: "ForumComment"

  has_many                :voices, -> { distinct(true) }, through: :forum_comments, source: :user

  validates_presence_of   :user_id, :forum_site_id, :forum_id, :title
  validates_presence_of   :body, on: :create

  default_scope           { where(account_id: Account.current.id) }

  # use babosa gem (to_slug) to allow better handling of multi-language slugs
  #------------------------------------------------------------------------------
  def model_slug
    title
  end

  # The first comment on a topic is the topic text.  So the number of *replies*
  # is the number of comments - 1
  #------------------------------------------------------------------------------
  def num_replies
    comments_count - 1
  end

  #------------------------------------------------------------------------------
  def to_s
    title
  end

  #------------------------------------------------------------------------------
  def sticky?
    sticky
  end

  #------------------------------------------------------------------------------
  def hit!
    self.class.increment_counter :hits, id
  end

  #------------------------------------------------------------------------------
  def paged?
    comments_count > ForumComment.per_page
  end

  #------------------------------------------------------------------------------
  def last_page
    [(comments_count.to_f / ForumComment.per_page).ceil.to_i, 1].max
  end

  #------------------------------------------------------------------------------
  def comment_number(forum_comment)
    forum_comments.where("id <= #{forum_comment.id}").count
  end

  #------------------------------------------------------------------------------
  def comment_page(forum_comment)
    [(comment_number(forum_comment).to_f / ForumComment.per_page).ceil.to_i, 1].max
  end

  #------------------------------------------------------------------------------
  def update_cached_comment_fields(forum_comment)
    #--- these fields are not accessible to mass assignment
    if remaining_comment = forum_comment.frozen? ? recent_comment : forum_comment
      self.class.where(id: id).update_all(last_updated_at: remaining_comment.created_at,
                                          last_user_id: remaining_comment.user_id, last_forum_comment_id: remaining_comment.id)
    else
      destroy
    end
  end

  protected

  #------------------------------------------------------------------------------
  def create_initial_comment
    forum_comments.create_comment(self, body, user)
    @body = nil
  end

  #------------------------------------------------------------------------------
  def set_default_attributes
    self.forum_site_id     = forum.forum_site_id if forum_id
    self.sticky          ||= 0
    self.last_updated_at ||= Time.now.utc
  end

  #------------------------------------------------------------------------------
  def check_for_moved_forum
    old = ForumTopic.find(id)
    @old_forum_id = old.forum_id if old.forum_id != forum_id
    true
  end

  #------------------------------------------------------------------------------
  def set_comment_forum_id
    return unless @old_forum_id

    Forum.where(id: @old_forum_id).update_all("comments_count = comments_count - #{comments_count}")
    Forum.where(id: forum_id).update_all("comments_count = comments_count + #{comments_count}")
    Forum.where(id: @old_forum_id).update_all("forum_topics_count = forum_topics_count - 1")
    Forum.where(id: forum_id).update_all("forum_topics_count = forum_topics_count + 1")
  end

  #------------------------------------------------------------------------------
  def count_user_comments_for_counter_cache
    @user_comments = forum_comments.group_by(&:user_id)
  end

  #------------------------------------------------------------------------------
  def update_cached_forum_and_user_counts
    Forum.where(id: forum_id).update_all("comments_count = comments_count - #{comments_count}")
    # @user_comments.each do |user_id, comments|
    #   User.where(:id => user_id).update_all("comments_count = comments_count - #{forum_comments.size}")
    # end
  end
end
