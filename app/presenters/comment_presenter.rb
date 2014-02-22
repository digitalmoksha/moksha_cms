class CommentPresenter < BasePresenter

  presents :comment

  #------------------------------------------------------------------------------
  def formatted_comment
    if (comment.user.is_admin?)
      #--- allow an admin user to put in full markdown/liquid
      liquidize_markdown(comment.body, {})
    else
      markdown(comment.body, :safe => true)
    end
  end
  
  #------------------------------------------------------------------------------
  def date_posted
    format_datetime comment.created_at
  end
  
  #------------------------------------------------------------------------------
  def author
    comment.user.nil? ? 'Anonymous' : comment.user.display_name
  end
  
end