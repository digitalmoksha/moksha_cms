class ForumComment < Comment
  #--- counter cache is set in the Comment model
  belongs_to              :forum_topic, :polymorphic => true, :foreign_key => :commentable_id, :foreign_type => :commentable_type

  #--- update counter cache in forum
  after_create            :increment_forum_counter_cache
  after_destroy           :decrement_forum_counter_cache

  default_scope           { where(account_id: Account.current.id) }

  validates_presence_of   :user_id, :body
  validate                :topic_is_not_locked

  after_create            :update_cached_fields
  after_update            :update_cached_fields
  after_destroy           :update_cached_fields

  self.per_page = 10

  # For a forum topic, we have one root comment, which is the body of the topic.
  # All other comments are either children or siblings
  #------------------------------------------------------------------------------
  def self.create_comment(forum_topic, body, user, parent_comment = nil)
    unless parent_comment
      #--- if it's the first comment, make it the root, otherwise it's a child
      parent_comment    = (forum_topic.forum_comments.empty? ? nil : forum_topic.forum_comments[0].root)
    end
    forum_topic.forum_comments.build(:body => body).tap do |comment|
      comment.user      = user
      comment.parent    = parent_comment
      comment.save
    end
  end

  #------------------------------------------------------------------------------
  def self.search(query, options = {})
    #--- (Beast) had to change the other join string since it conflicts when we bring parents in
    options[:conditions] ||= ["LOWER(#{ForumComment.table_name}.body) LIKE ?", "%#{query}%"] unless query.blank?
    options[:select]     ||= "#{ForumComment.table_name}.*, #{ForumTopic.table_name}.title as topic_title, f.name as forum_name"
    options[:joins]      ||= "inner join #{ForumTopic.table_name} on #{ForumComment.table_name}.topic_id = #{ForumTopic.table_name}.id " +
      "inner join #{Forum.table_name} as f on #{ForumTopic.table_name}.forum_id = f.id"
    options[:order]      ||= "#{ForumComment.table_name}.created_at DESC"
    options[:count]      ||= { :select => "#{ForumComment.table_name}.id" }
    paginate options
  end

  #------------------------------------------------------------------------------
  def self.search_monitored(user_id, query, options = {})
    #--- (Beast) Same as above, but select only posts in topics monitored by the given user
    # [todo]
    # options[:conditions] ||= ["LOWER(#{ForumComment.table_name}.body) LIKE ?", "%#{query}%"] unless query.blank?
    # options[:select]     ||= "#{ForumComment.table_name}.*, #{ForumTopic.table_name}.title as topic_title, f.name as forum_name"
    # options[:joins]      ||= "inner join #{ForumTopic.table_name} on #{ForumComment.table_name}.topic_id = #{ForumTopic.table_name}.id " +
    #                          "inner join #{Forum.table_name} as f on #{ForumTopic.table_name}.forum_id = f.id " +
    #                          "inner join #{Monitorship.table_name} as m on #{ForumComment.table_name}.topic_id = m.topic_id AND " +
    #                          "m.user_id = #{user_id} AND m.active != 0"
    # options[:order]      ||= "#{ForumComment.table_name}.created_at DESC"
    # options[:count]      ||= {:select => "#{ForumComment.table_name}.id"}
    # paginate options
  end

  #------------------------------------------------------------------------------
  def forum_name
    forum_topic.forum.name
  end

  protected

  #------------------------------------------------------------------------------
  def update_cached_fields
    forum_topic.update_cached_comment_fields(self) unless forum_topic.nil?
  end

  #------------------------------------------------------------------------------
  def topic_is_not_locked
    errors.add(:base, "Topic is locked") if forum_topic && forum_topic.locked? && forum_topic.comments_count > 0
  end

  private

  # Since we can't have a belongs_to to the specific forum, update the comment
  # counter cache by hand
  #------------------------------------------------------------------------------
  def increment_forum_counter_cache
    Forum.increment_counter('comments_count', self.forum_topic.forum.id)
  end

  def decrement_forum_counter_cache
    Forum.decrement_counter('comments_count', self.forum_topic.forum.id) unless self.forum_topic.nil?
  end
end