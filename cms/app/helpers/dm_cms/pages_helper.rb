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
      items = @current_page.cms_contentitems.find_all_by_container(name)
      render :partial => (items.nil? ? 'not_found' : 'content_fragment'), :collection => items
    end
  end

  # Given the name of a container, check if any content is available
  #------------------------------------------------------------------------------
  def content_by_name?(name)
    (@current_page.nil? || @current_page.cms_contentitems.count(conditions: [ "container = ?", name ]) == 0) ? false : true
  end

  #------------------------------------------------------------------------------
  def render_content_item(content_item)
    if content_item.content.nil?
      content = ""
    else
      # --- process content type
      case content_item.itemtype.downcase
        when 'textile'
          xcontent = render :inline => content_item.content
          #content = textilize(xcontent)
          content = liquidize_textile(xcontent, {})
        when 'markdown'
          xcontent = render :inline => content_item.content
          #content = markdown(xcontent, :safe => false)
          content = liquidize_markdown(xcontent, {})
        when 'html'
          xcontent = render :inline => content_item.content
          content = liquidize_html(xcontent, {})
        else
          content = ""
      end
    end
    return content
  end

  #------------------------------------------------------------------------------
  def main_menu(options = {})
    return '' if (root = CmsPage.roots[0]).nil?

    menu_str                 = ''
    options[:ul]             = ''
    options[:ul]            += "class='#{options[:class]}' "  unless options[:class].blank?
    options[:ul]            += "id='#{options[:id]}' "        unless options[:id].blank?
    options[:include_root]   = root                  if options[:include_home]
    options[:active_class] ||= 'current'
    children    = root.subtree.arrange(order: :position).to_a[0][1]
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
    menu_str = ("<ul #{options[:ul]}>" + menu_str + "</ul>")
  end
  
  # return true if the page should be allowed to be dislpayed in a menu
  #------------------------------------------------------------------------------
  def allow_page_in_menu?(page)
    (page.is_published? || is_admin?) && page_authorized?(page) && !page.menutitle.blank?    
  end
  
  #------------------------------------------------------------------------------
  def main_menu_select(options = {})
    return '' if (root = CmsPage.roots[0]).nil?
    options[:id]            ||= ''
    options[:class]         ||= ''
    options[:include_root]    = root if options[:include_home]
    pages                     = root.subtree.arrange(order: :position).to_a[0][1]
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
  # Given the name of a container, queries for all content items for that 
  # container within the given page.
  #------------------------------------------------------------------------------
  def snippet_by_name( name )
    @items = current_account.cms_snippets.find_all_by_container(name)
    render :partial => (@items.nil? ? 'not_found' : 'snippet_fragment'), :collection => @items
  end

  # -- Preferred method
  # given the accessname of a section, builds a list of links of all children of 
  # the specific section.
  #------------------------------------------------------------------------------
  def build_menu_for_section(accessname, options = {})
    temp_page   = current_account_site.cms_pages.find_by_accessname(accessname)
    if temp_page
      pages       = current_account_site.cms_pages.find_all_by_parent_id(temp_page.id, :order => :position)
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
    pages = current_account_site.cms_pages.find_all_by_parent_id(queryID, :order => :position)
    menu_from_pages(pages, options)
  end
  


=end
end
