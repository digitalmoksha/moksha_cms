class ForumComment < Comment

  #--- counter cache is set in the Comment model
  belongs_to              :forum_topic, :polymorphic => true, :foreign_key => :commentable_id, :foreign_type => :commentable_type

  #--- update counter cache in forum
  after_create            :increment_forum_counter_cache
  after_destroy           :decrement_forum_counter_cache

  default_scope           { where(account_id: Account.current.id) }

  validates_presence_of   :user_id, :body

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
  
private

  # Since we can't have a belongs_to to the specific forum, update the comment
  # counter cache by hand
  #------------------------------------------------------------------------------
  def increment_forum_counter_cache
      Forum.increment_counter( 'comments_count', self.forum_topic.forum.id )
  end

  def decrement_forum_counter_cache
      Forum.decrement_counter( 'comments_count', self.forum_topic.forum.id )
  end

end