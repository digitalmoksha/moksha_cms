module DmCms::PostsHelper
  include DmCore::LiquidHelper
  
  
  # Display the blog summary.  Support liquid tags and markdown in the summary
  # field.  If the there is no summary, grab the first :words from the content
  # Note: can't support liquid in emails right now.  The path to the assets is not
  # generated correctly, and the styles mostly likely don't match.  For now,
  # strip out liquid for emails
  #------------------------------------------------------------------------------
  def display_post_summary(post, options = {})
    options.reverse_merge!(words: 50, email: false)
    
    if !post.summary.blank?
      options[:email] ? markdown(post.summary, safe: false) : liquidize_markdown(post.summary)
    else
      post.content.blank? ? '' : (options[:email] ? markdown(post.content.smart_truncate(options[:words]), safe: false) : liquidize_markdown(post.content.smart_truncate(options[:words])))
    end
  end
  
  #------------------------------------------------------------------------------
  def display_post_content(post)
    post.content.blank? ? '' : liquidize_markdown(post.content)
  end

end
