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
      render :partial => 'dm_cms/pages/snippet_fragment', locals: { snippet_fragment: cms_snippet }
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
    return '' if (root = CmsPage.roots.first).nil?

    menu_str                 = ''
    options[:ul]             = ''
    options[:ul]            += "class=\"#{options[:class]}\" "  unless options[:class].blank?
    options[:ul]            += "id=\"#{options[:id]}\" "        unless options[:id].blank?
    options[:include_root]   = root if options[:include_home]
    options[:active_class] ||= 'current'
    children                 = root.subtree.includes(:translations).arrange(order: :row_order).to_a[0][1]
    menu_str, submenu_active = case options[:type]
                               when :bs3
                                 menu_from_pages_bs3(children, options)
                               when :bs4
                                 menu_from_pages_bs4(children, options)
                               else
                                 menu_from_pages(children, options)
    end
    return menu_str.html_safe
  end

  #------------------------------------------------------------------------------
  def menu_from_pages(pages, options = {})
    options[:ul]  ||= ''
    menu_str        = ''
    active_found    = false
    if (root = options[:include_root]) && allow_page_in_menu?(root)
      active          = (on_current_page?(root) ? options[:active_class] : nil)
      active_found  ||= !active.nil?
      menu_str       += content_tag :li, page_link(root), class: active
    end
    pages.each do |page, children|
      if allow_page_in_menu?(page)
        ul_class = options[:sub_menu_1] ? "class=\"#{options[:sub_menu_1]}\"" : ''
        submenu, submenu_active = (children.empty? ? '' : menu_from_pages(children, active_class: options[:active_class], ul: ul_class))
        active                  = (submenu_active || on_current_page?(page) ? options[:active_class] : nil)
        active_found          ||= !active.nil?
        menu_str += content_tag(:li, class: active) do
          page_link(page) +
            submenu.html_safe
        end
      end
    end
    return (menu_str.blank? ? '' : "<ul #{options[:ul]}>#{menu_str}</ul>"), active_found
  end

  # Creates a standard Bootstrap 3 version of a main menu
  #------------------------------------------------------------------------------
  def menu_from_pages_bs3(pages, options = {})
    options[:ul]  ||= ''
    menu_str        = ''
    active_found    = false
    if (root = options[:include_root])
      active          = (on_current_page?(root) ? options[:active_class] : nil)
      active_found  ||= !active.nil?
      menu_str       += content_tag :li, page_link(root), class: active
    end
    pages.each do |page, children|
      if allow_page_in_menu?(page)
        submenu, submenu_active = (children.empty? ? '' : menu_from_pages_bs3(children, ul: 'class="dropdown-menu"', active_class: options[:active_class]))
        active                  = (submenu_active || on_current_page?(page) ? options[:active_class] : nil)
        active_found          ||= !active.nil?
        if !submenu.blank?
          menu_str += content_tag(:li, class: ['dropdown', active].css_join(' ')) do
            page_link(page, ''.html_safe + page.menutitle + ' <b class="caret"></b>'.html_safe, class: 'dropdown-toggle', data: { toggle: 'dropdown' }) +
              submenu.html_safe
          end
        else
          menu_str += content_tag :li, page_link(page), class: active
        end
      end
    end
    return (menu_str.blank? ? '' : "<ul #{options[:ul]}>#{menu_str}</ul>"), active_found
  end

  # Creates a standard Bootstrap 3 version of a main menu
  #------------------------------------------------------------------------------
  def menu_from_pages_bs4(pages, options = {})
    options[:ul]  ||= ''
    menu_str        = ''
    active_found    = false
    if (root = options[:include_root])
      active          = (on_current_page?(root) ? options[:active_class] : nil)
      active_found  ||= !active.nil?
      menu_str       += content_tag :li, page_link(root, nil, class: 'nav-link'), class: ['nav-item', active].css_join(' ')
    end
    pages.each do |page, children|
      if allow_page_in_menu?(page)
        submenu, submenu_active = (children.empty? ? '' : menu_from_pages_bs4(children, ul: 'class="dropdown-menu"', active_class: options[:active_class]))
        active                  = (submenu_active || on_current_page?(page) ? options[:active_class] : nil)
        active_found          ||= !active.nil?
        if !submenu.blank?
          menu_str += content_tag(:li, class: ['nav-item', 'dropdown', active].css_join(' ')) do
            page_link(page, ''.html_safe + page.menutitle + ' <b class="caret"></b>'.html_safe, class: 'nav-link dropdown-toggle', data: { toggle: 'dropdown' }) +
              submenu.html_safe
          end
        else
          menu_str += content_tag :li, page_link(page, nil, class: 'nav-link'), class: ['nav-item', active].css_join(' ')
        end
      end
    end
    return (menu_str.blank? ? '' : "<ul #{options[:ul]}>#{menu_str}</ul>"), active_found
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
    pages                     = root.subtree.includes(:translations).arrange(order: :row_order).to_a[0][1]
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
  def page_link(page, text = nil, options = {})
    text    ||= page.menutitle
    options   = options.merge(target: '_blank') if page.preferred_open_in_new_window?
    link_to(text, redirect_link(page.link) || redirect_link(page.slug), options)
  end

  # determine where to redirect based on the style of the link
  # always ensure there is a locale on the front unless it's a fully
  # qualified link
  #------------------------------------------------------------------------------
  def redirect_link(link)
    return nil if link.blank?

    begin
      uri = URI.parse(link)
    rescue URI::InvalidURIError
    end
    if uri && uri.host
      link # fully qualified url
    else
      if link.start_with?('/')
        dm_cms.showpage_url(slug: link[1..-1]) # absolute link to this site, with no host/scheme
      else
        dm_cms.showpage_url(slug: link) # relative link/slug
      end
    end
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
  def on_current_page?(page)
    (@current_page == page) ? true : false
  end

  # Use the request url to determine if the current url matches any passed in paths
  # http://stackoverflow.com/questions/8552763/best-way-to-highlight-current-page-in-rails-3-apply-a-css-class-to-links-con
  #------------------------------------------------------------------------------
  def current_page_path?(*paths)
    active = false
    paths.each { |path| active ||= request.url.include?(path) }
    return active
  end

  # Determine if the page is in this section
  # {todo} should be able to go to any depth
  #------------------------------------------------------------------------------
  def page_in_section?(page)
    (@current_page == page or @current_page.parent_id == page.id) ? true : false
  end
end
