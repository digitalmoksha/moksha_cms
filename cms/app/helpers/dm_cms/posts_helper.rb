module DmCms::PostsHelper
  
  #------------------------------------------------------------------------------
  def render_post_content(post)
    if post.content.nil?
      content = ""
    else
      # --- process as markdown
      xcontent = render :inline => post.content
      content = liquidize_markdown(xcontent, {})
    end
    return content
  end

end
