class CmsPagePresenter < BasePresenter

  presents :cms_page

  #------------------------------------------------------------------------------
  def label_published
    cms_page.is_published? ? h.colored_label('Published', :success) : h.colored_label('Draft')
  end
  
end