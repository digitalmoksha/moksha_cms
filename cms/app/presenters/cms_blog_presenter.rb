class CmsBlogPresenter < BasePresenter

  presents :cms_blog

  #------------------------------------------------------------------------------
  def label_published
    cms_blog.is_published? ? h.colored_label('Published', :success) : h.colored_label('Draft')
  end
  
  #------------------------------------------------------------------------------
  def visibility
    cms_blog.is_private? ? 'private' : (cms_blog.is_protected? ? 'protected' : 'public')
  end
  
end