# Handles building the different content streams for a page
#------------------------------------------------------------------------------
module DmCms::PagesHelper
  
  # Easy way to get a page url
  # slug can either be a string, or a CmsPage object
  #------------------------------------------------------------------------------
  def page_url(slug, locale = DmCore::Language.locale)
    showpage_url(:locale => locale, :slug => (slug.kind_of?(CmsPage) ? slug.slug : slug))
  end
  
  # Given the name of a container, queries for all content items for that 
  # container within the given page.
  #------------------------------------------------------------------------------
  def content_by_name( name )
    unless @current_page.nil?
      items = @current_page.cms_contentitems.where(container: name)
      render :partial => (items.nil? ? 'not_found' : 'content_fragment'), :collection => items
    end
  end

  # Given the name of a container, check if any content is available
  #------------------------------------------------------------------------------
  def content_by_name?(name)
    (@current_page.nil? || @current_page.cms_contentitems.where(container: name).count == 0) ? false : true
  end

  #------------------------------------------------------------------------------
  def snippet(slug)
    cms_snippet = CmsSnippet.find_by_slug(slug)
    if cms_snippet
      render :partial => 'dm_cms/pages/snippet_fragment', locals: {snippet_fragment: cms_snippet}
    else
      render text: 'Snippet not found'
    end
  end

  #------------------------------------------------------------------------------
  def snippet?(slug)
    CmsSnippet.where(slug: slug).count == 0 ? false : true
  end

  #------------------------------------------------------------------------------
  def render_content_item(content_item)
    if content_item.content.blank?
      content = ''
    else
      # --- process content type
      liquid_params = content_item.to_liquid
      liquid_params.reverse_merge!(current_user.to_liquid) if current_user
      case content_item.itemtype.downcase
        when 'textile'
          content = liquidize_textile(content_item.content, liquid_params)
        when 'markdown'
          content = liquidize_markdown(content_item.content, liquid_params)
        when 'html'
          content = liquidize_html(content_item.content, liquid_params)
        else
          content = ''
      end
    end
    return content
  end

  # Generates a simple multi-level page menu including children
  #------------------------------------------------------------------------------
  def main_menu(options = {})
    return '' if (root = CmsPage.roots[0]).nil?

    menu_str                 = ''
    options[:ul]             = ''
    options[:ul]            += "class='#{options[:class]}' "  unless options[:class].blank?
    options[:ul]            += "id='#{options[:id]}' "        unless options[:id].blank?
    options[:include_root]   = root                  if options[:include_home]
    options[:active_class] ||= 'current'
    children    = root.subtree.arrange(order: :row_order).to_a[0][1]
    menu_str    = menu_from_pages(children, options)
    return menu_str.html_safe
  end

  #------------------------------------------------------------------------------
  def menu_from_pages(pages, options = {})
    options[:ul]  ||= ''
    menu_str        = ''
    if (root = options[:include_root])
      active = (current_page?(root) ? options[:active_class] : '')
      menu_str += "<li class='#{active}'>#{link_to root.menutitle, dm_cms.showpage_url(root.slug)}</li>"
    end
    pages.each do |page, children|
      if allow_page_in_menu?(page)
        submenu = (children.empty? ? '' : menu_from_pages(children))
        active = (current_page?(page) ? options[:active_class] : '')
        menu_str += "<li>#{link_to page.menutitle, dm_cms.showpage_url(page.slug)}#{submenu}</li>"
      end
    end
    return (menu_str.blank? ? '' : "<ul #{options[:ul]}>#{menu_str}</ul>")
  end
  
  # return true if the page should be allowed to be dislpayed in a menu
  #------------------------------------------------------------------------------
  def allow_page_in_menu?(page)
    page.present? && (page.is_published? || is_admin?) && page_authorized?(page) && !page.menutitle.blank?    
  end
  
  #------------------------------------------------------------------------------
  def main_menu_select(options = {})
    return '' if (root = CmsPage.roots[0]).nil?
    options[:id]            ||= ''
    options[:class]         ||= ''
    options[:include_root]    = root if options[:include_home]
    pages                     = root.subtree.arrange(order: :row_order).to_a[0][1]
    menu_str                  = "<select id='#{options[:id]}' class='#{options[:class]}'>"
    menu_str                 += "<option value='' selected='selected'>#{nls(:main_menu_select_prompt)}</option>"
    if options[:include_home]
      menu_str += "<option value='#{dm_cms.showpage_url(root.slug)}'>#{root.menutitle}</option>"
    end
    pages.each do |page, children|
      if allow_page_in_menu?(page)
        menu_str += "<option value='#{dm_cms.showpage_url(page.slug)}'>#{page.menutitle}</option>"
      end
    end
    menu_str += "</select>"
    return menu_str.html_safe
  end
  
  # return a link to the page's slug, with the passed in link text
  #------------------------------------------------------------------------------
  def page_link(page, text)
    text ||= ''
    link_to text.html_safe, dm_cms.showpage_url(page.slug)
  end
  
  private

  # Currently check is page requires a login and if user is logged in.  
  # {todo} add additional authorization checks
  #------------------------------------------------------------------------------
  def page_authorized?(page)
    if page.requires_login? 
      return user_signed_in?
    else
      true
    end
  end

  # Determine if this page is currently being  displayed
  #------------------------------------------------------------------------------
  def current_page?(page)
    (@current_page == page) ? true : false
  end

  # Determine if the page is in this section
  # {todo} should be able to go to any depth
  #------------------------------------------------------------------------------
  def page_in_section?(page)
    (@current_page == page or @current_page.parent_id == page.id) ? true : false
  end

=begin  
  # -- Preferred method
  # given the accessname of a section, builds a list of links of all children of 
  # the specific section.
  #------------------------------------------------------------------------------
  def build_menu_for_section(accessname, options = {})
    temp_page   = current_account_site.cms_pages.find_by_accessname(accessname)
    if temp_page
      pages       = current_account_site.cms_pages.where(parent_id: temp_page.id).rank(:row_order)
      menu_from_pages(pages, options)
    end
  end

  #------------------------------------------------------------------------------
  def build_menu_for_single_page(accessname, options = {})
    temp_page   = current_account_site.cms_pages.find_by_accessname(accessname)
    options[:only_lineitem] = true
    menu_from_pages([temp_page], options) if temp_page
  end
  
  # -- Preferred method
  #------------------------------------------------------------------------------
  def build_menu_for_page(options = {})
    return if @cms_page[:page_id].nil?

    if @cms_page[:level] == 1
      # --- at a level one, grab the children
      queryID = @cms_page[:page_id]
    else
      # --- we're at second level (or greater {todo}), use the parent_id to get siblings
      tempPage = current_account_site.cms_pages.find(@cms_page[:page_id])
      queryID =  tempPage.parent_at_level(1)
    end
    pages = current_account_site.cms_pages.where(parent_id: queryID).rank(:row_order)
    menu_from_pages(pages, options)
  end
  


=end
end
