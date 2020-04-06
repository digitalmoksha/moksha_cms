class CommentPresenter < BasePresenter
  presents :comment

  #------------------------------------------------------------------------------
  def formatted_comment
    markdown(comment.body, safe: true)
  end

  #------------------------------------------------------------------------------
  def date_posted(options = {})
    format_datetime(comment.created_at, options)
  end

  #------------------------------------------------------------------------------
  def author
    comment.user.nil? ? 'Anonymous' : comment.user.display_name
  end
end
