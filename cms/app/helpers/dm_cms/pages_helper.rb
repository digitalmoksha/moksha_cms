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
          content = liquidize(xcontent, {})
        when 'markdown'
          xcontent = render :inline => content_item.content
          content = markdown(xcontent, :safe => false)
        when 'erb'
          content = render :inline => content_item.content
        else
          content = ""
      end
    end
    return content
  end

=begin
  #------------------------------------------------------------------------------
  def menu_list_from_page(page, level)
    menu ||= []
    while level > 0
      children = 
    end
  end
  
  private
    #------------------------------------------------------------------------------
    def menu_from_pages(pages, options = {})
      options[:use_cookies] ||= {}
      menu_str    = ul_options = ''
      ul_options += "class=\"#{options[:class]}\" " unless options[:class].blank?
      ul_options += "id=\"#{options[:id]}\" " unless options[:id].blank?

      if options[:include_home]
        home = current_account_site.cms_pages.find_by_level(0)
        menu_str += "<li>" + link_to(home.menutitle, showpage_url(:locale => @cms_page[:lang], :accessname => home.accessname)) + "</li>"
      end

      unless pages.nil?
        pages.each do |p|
          if p.is_published? && page_authorized?(p) && p.accessname != "missing" && p.visited?(options[:use_cookies])
            unless p.menutitle.blank?
              if page_in_section?(p)
                menu_str += '<li class="active">' + link_to(p.menutitle, showpage_url(:locale => @cms_page[:lang], :accessname => p.accessname)) + "</li>"
              else
                menu_str += "<li>" + link_to(p.menutitle, showpage_url(:locale => @cms_page[:lang], :accessname => p.accessname)) + "</li>"
              end
            end
          end
        end
        if options[:include_hanuman]
          menu_str += "<li>" + link_to('Hanuman', showpage_url(:locale => @cms_page[:lang], :accessname => 'hanuman')) + "</li>"
        end
        menu_str = ("<ul #{ul_options}>" + menu_str + "</ul>") unless options[:only_lineitem]
      end
      return menu_str.html_safe
    end
=end

=begin  
  # Given the name of a container, queries for all content items for that 
  # container within the given page.
  #------------------------------------------------------------------------------
  def snippet_by_name( name )
    @items = current_account.cms_snippets.find_all_by_container(name)
    render :partial => (@items.nil? ? 'not_found' : 'snippet_fragment'), :collection => @items
  end

  # -- Deprecated - [todo] Used for kaleshwar.eu and university site.
  # Rewrite and remove at some point
  # Generic menu builder.  By specifying a symbol such as :main or :second, will build
  # the corresponding menu by walking the pages.
  #------------------------------------------------------------------------------
  def build_menubar(levelSym = :main)
    menuStr = ""
    bShowActive = true
    case levelSym
      when :home
        pages = current_account_site.cms_pages.find_all_by_level(0)
        bShowActive = false
      when :main, :main_second
        pages = current_account_site.cms_pages.find_all_by_level(1, :order => :position)
      when :second
        if @cms_page[:page_id].nil?
          pages = nil
        else
          if @cms_page[:level] == 1
            # --- at a level one, grab the children
            queryID = @cms_page[:page_id]
          else
            # --- we're at second level (or greater {todo}), use the parent_id to get siblings
            tempPage = current_account_site.cms_pages.find(@cms_page[:page_id])
            queryID =  tempPage.parent_at_level(1)
          end
          pages = current_account_site.cms_pages.find_all_by_parent_id(queryID, :order => :position)
        end
        
      when :children
        pages = current_account_site.cms_pages.find_all_by_parent_id(@cms_page[:page_id], :order => :position)
    end

    unless pages.nil?
      pages.each do |p|
        if p.is_published? && page_authorized?(p)
          unless p.menutitle.blank?
            html_options = (bShowActive and page_in_section?(p) ? {:id => "active"} : {})
            link_title = (p.menuimage.blank? ? p.menutitle : 
               image_tag("/images/"  + @cms_page[:lang] + "/#{html_options ? 'active_' : ''}" + p.menuimage, :alt => p.menutitle, :title => p.menutitle))
            menuStr += link_to(link_title, showpage_url(:locale => @cms_page[:lang], :accessname => p.accessname))
            menuStr += build_menubar_from_page(p) if levelSym == :main_second
          end
        end
      end
    end
    return menuStr.html_safe
  end
  
  # -- Deprecated - [todo] Used only by build_menubar()
  # Rewrite and remove at some point
  #------------------------------------------------------------------------------
  def build_menubar_from_page(page)
    menuStr = ""
    pages = current_account_site.cms_pages.find_all_by_parent_id(page.id, :order => :position)
    unless pages.nil?
      menuStr += "<ul class=\"menu_level_#{(page.level + 1).to_s}\">"
      pages.each do |p|
        if p.is_published? && page_authorized?(p)        
          unless p.menutitle.blank?
            html_options = (page_in_section?(p) ? {:id => "active"} : nil)
            menuStr += "<li>" + link_to(p.menutitle, showpage_url(:locale => @cms_page[:lang], :accessname => p.accessname), html_options) + "</li>"
          end
        end
      end
      menuStr += "</ul>"
    end
    return menuStr
  end
  
  # -- Deprecated - use only by old kaleshwwar.org theme (2009)
  # Build a list based menu for a certain level
  # {todo} re-examine: not  sure this is doing what I expect it
  #------------------------------------------------------------------------------
  def build_menubar_level(level, options = {})
    menuStr = ""
    pages = current_account_site.cms_pages.find_all_by_level(level, :order => :position)
    unless pages.nil?
      menuStr += (options[:id].nil? ? '<ul>' : "<ul id=\"#{options[:id]}\">")
      pages.each do |p|
        if p.is_published? && page_authorized?(p)        
          unless p.menutitle.blank?
            html_options = (page_in_section?(p) ? {:id => "active"} : nil)
            menuStr += "<li>" + link_to(h(p.menutitle), showpage_url(:locale => @cms_page[:lang], :accessname => p.accessname), html_options) + "</li>"
          end
        end
      end
      menuStr += "</ul>"
    end
    return menuStr.html_safe
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
  
  # Determine if the page is in this section
  # {todo} should be able to go to any depth
  #------------------------------------------------------------------------------
  def page_in_section?(page)
    (@cms_page[:page_id] == page.id or @cms_page[:parent_id] == page.id) ? true : false
  end

  # Determine if this page is currently being  displayed
  #------------------------------------------------------------------------------
  def current_page?(page)
    (@cms_page[:page_id] == page.id) ? true : false
  end

  #------------------------------------------------------------------------------
  def page_authorized?(page)
    true
  end

=end
end
