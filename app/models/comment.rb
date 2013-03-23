# Generated from acts_as_commentable
#------------------------------------------------------------------------------
class Comment < ActiveRecord::Base
  self.table_name   = 'core_comments'
  attr_accessible   :comment, :title, :user_id

  include           ActsAsCommentable::Comment
  belongs_to        :commentable, :polymorphic => true

  default_scope     { where(account_id: Account.current.id).order("created_at ASC") }

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  # NOTE: Comments belong to a user
  belongs_to :user
  
end
