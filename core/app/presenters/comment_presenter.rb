class CommentPresenter < BasePresenter

  presents :comment

  #------------------------------------------------------------------------------
  def formatted_comment
    markdown(comment.body, :safe => true)
  end
  
  #------------------------------------------------------------------------------
  def date_posted
    h.distance_of_time_in_words_to_now(comment.created_at) + " ago"
  end
  
  #------------------------------------------------------------------------------
  def author
    comment.user.nil? ? 'Anonymous' : comment.user.first_name
  end
  
end