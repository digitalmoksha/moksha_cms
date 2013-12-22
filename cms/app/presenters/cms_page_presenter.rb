class CmsPagePresenter < BasePresenter

  presents :cms_page

  #------------------------------------------------------------------------------
  def label_published
    cms_page.is_published? ? h.colored_label('Published', :success) : h.colored_label('Draft')
  end
  
  # Prepare a title for admin Page views.  page/menu title with slug in <small>
  #------------------------------------------------------------------------------
  def admin_edit_title
    main_title  = (cms_page.title.present? ? cms_page.title : (cms_page.menutitle.present? ? cms_page.menutitle : '(no title)'))
    sub_title   = cms_page.slug

    #--- make sure it's built safely...
    html = "".html_safe
    html << main_title
    html << "<small>".html_safe
    html << sub_title
    html << "</small>".html_safe
  end
end