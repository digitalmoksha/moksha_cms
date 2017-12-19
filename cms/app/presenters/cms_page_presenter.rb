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
    sub_title   = 'Permalink: '.html_safe +
                  link_to(dm_cms.showpage_url(cms_page.slug), dm_cms.showpage_url(cms_page.slug), title: 'Permalink for this page', target: '_blank')

    #--- make sure it's built safely...
    html = "".html_safe
    html << main_title
    html << "&nbsp;<span class='fa fa-globe'></span>".html_safe if cms_page.welcome_page?
    html << "<small>".html_safe
    html << sub_title
    html << "</small>".html_safe
  end

  #------------------------------------------------------------------------------
  def visibility
    if cms_page.requires_login?
      icon_label(:protected, 'protected', icon_class: 'text-danger')
    else
      icon_label(:public, 'public', icon_class: 'text-success')
    end
  end
end