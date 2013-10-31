module DmCms::PostsHelper
  include DmCore::LiquidHelper
  
  
  # Display the blog summary.  Support liquid tags and markdown in the summary
  # field.  If the there is no summary, grab the first :words from the content
  #------------------------------------------------------------------------------
  def display_post_summary(post, options = {words: 50})
    if !post.summary.blank?
      liquidize_markdown(post.summary)
    else
      post.content.blank? ? '' : liquidize_markdown(post.content.smart_truncate(options[:words]))
    end
  end
  
  #------------------------------------------------------------------------------
  def display_post_content(post)
    post.content.blank? ? '' : liquidize_markdown(post.content)
  end

end
