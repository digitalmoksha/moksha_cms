# Helper methods for virtualizing aspects of the Amsterdam Theme
# The render_admin helper also contains some functions as well
#------------------------------------------------------------------------------
module Admin::ThemeAmsterdamHelper
  
  #--- values used for the theme style, and for id on the body tag
  THEMES = %w(teal dark)
  
  # Helper for using the Font Awesome or Bootstrap icons
  # params:
  #   icon_type => name of the class for the icon ie. font-camera for Font Awesome
  #                or icon-camera for Bootstrap
  #   :size     => such as 32, gives a font size of 32px
  #------------------------------------------------------------------------------
  def icons(icon_type, options = {})
    style  = ''
    style += (options[:size].blank?  ? '' : "font-size:#{options[:size]}px;")
    style += (options[:color].blank? ? '' : "color:#{options[:color]};")
    style  = (style.blank? ? '' : "style='#{style}'")
    
    "<i class='#{icon_type}' #{style}></i>".html_safe
  end
  
  #------------------------------------------------------------------------------
  def icon_label(icon_type, text, options = {})
    "#{icons(icon_type, options)} #{text}".html_safe
  end
    
  # A colored text label.
  # style => :success, :important, :info, :warning, inverse
  #------------------------------------------------------------------------------
  def colored_label(text, style = :plain)
    if style == :plain
      "<span class='label'>#{text}</span>".html_safe
    else
      "<span class='label label-#{style.to_s}'>#{text}</span>".html_safe
    end
  end

  #------------------------------------------------------------------------------
  def content_box(options = {}, &block)
    options[:title]         ||= ''
    options[:id]            ||= ''
    options[:class]         ||= ''
    options[:toolbar]       ||= ''
    options[:include_general] = options[:include_general].nil? ? true : options[:include_general]
    
    if options[:toolbar] == :languages
      options[:toolbar] = language_toolbar_tabs(options[:include_general])
      options[:class] += ' navbar-tabs'
    end

    content = with_output_buffer(&block)
    content_tag :div, :id => options[:id], :class => "block well #{options[:class]}" do
      "<div class='navbar'><div class='navbar-inner'><h5>#{options[:title]}</h5>#{options[:toolbar]}</div></div>".html_safe +
      content_tag(:div, content, :class => 'body')
    end
  end

  # Similar to a content_box, but don't wrap the content in a div "body" tag, which has
  # margins/padding.  Useful for forms and tables
  #------------------------------------------------------------------------------
  def content_frame(options = {}, &block)
    options[:title]         ||= ''
    options[:id]            ||= ''
    options[:class]         ||= ''
    options[:toolbar]       ||= ''
    options[:include_general] = options[:include_general].nil? ? true : options[:include_general]
    
    if options[:toolbar] == :languages
      options[:toolbar] = language_toolbar_tabs(options[:include_general])
      options[:class] += ' navbar-tabs'
    end
    
    content = with_output_buffer(&block)
    content_tag :div, :id => options[:id], :class => "block well #{options[:class]}" do
      "<div class='navbar'><div class='navbar-inner'><h5>#{options[:title]}</h5>#{options[:toolbar]}</div></div>".html_safe +
      content
    end
  end

  # Displays a "well" with content, flush to the edges.  Optional title and explanation
  # text
  #------------------------------------------------------------------------------
  def well_frame(options = {}, &block)
    options[:title]         ||= ''
    options[:id]            ||= ''
    options[:class]         ||= ''
    options[:explanation]   ||= ''
    heading                   = ''
    
    heading += "<h6 class='subtitle'>#{options[:title]}</h6>" unless options[:title].blank?
    heading += "<p class='explanation'>#{options[:explanation]}</p>" unless options[:explanation].blank?
    
    content = with_output_buffer(&block)
    content_tag :div, :id => options[:id], :class => "semi-block #{options[:class]}" do
      heading.html_safe + content_tag(:div, content, :class => 'well')
    end
  end

  # A tabbed frame with locales as the tabs
  #------------------------------------------------------------------------------
  def locale_frame(options = {}, &block)
    options[:title]         ||= ''
    options[:id]            ||= ''
    options[:class]         ||= ''
    options[:toolbar]         = language_toolbar_tabs(false)
    options[:class]          += ' navbar-tabs'

    # content = with_output_buffer(&block)
    # render :partial => 'dm_core/admin/shared/locale_frame', :locals => { :options => options, :content => content }
    
    content = {}
    current_account.site_locales.each do |locale|
      content[locale] = capture(locale, &block)
    end
    render :partial => 'dm_core/admin/shared/locale_frame', :locals => { :options => options, :content => content }
  end

  # :save => save text
  # :cancel => cancel text (if it == false, then only show the save button)
  # :cancel_url => url (or hash) to be linked to
  # :slide => id of div to toggle slide
  #------------------------------------------------------------------------------
  def submit_or_cancel(options = {})
    options[:save]        ||= 'Save'
    options[:cancel]        = 'Cancel' if options[:cancel].nil?
    options[:cancel_url]  ||= ''
    options[:indicator]   ||= ''

    out =  "<div class='form-actions align-right'>"
    #--- check if we want a cancel button
    if options[:cancel] != false
      if options[:cancel_url].blank?
        #--- if no url specified, assume sliding the div closed
        out << "#{link_to options[:cancel], '#', :class => 'toggle_link btn', :data => { :toggleid => options[:slide] } }"
      elsif options[:cancel_url] == 'close-modal'
        out << "#{link_to options[:cancel], '#', :class => 'btn', :data => { :dismiss => 'modal' } }"
      else
        out << "#{link_to options[:cancel], options[:cancel_url], {:class => 'btn'} }"
      end
      out << "<span class='submit_or'>&nbsp;&nbsp;&nbsp;&nbsp;</span>"
    end

    out << "#{submit_tag options[:save], :class => 'btn btn-primary'}"
    
    #--- add the indicator
    #out << "#{image_tag_plugin('indicator_small.gif', :id => options[:indicator], :style => 'padding-left:10px;display:none;border:none;')}"
    out << "<div class='clear'></div>"
    out << "</div>"
    return out.html_safe
  end
  
  #------------------------------------------------------------------------------
  def toolbar_button(label, url, options = {})
    options[:class] ||= 'btn btn-mini btn-primary pull-right'
    options[:title] ||= label
    link_to(label, url, :title => options[:title], :class => options[:class], :style => options[:style])
  end
  
  #------------------------------------------------------------------------------
  def language_toolbar_tabs(include_general = true)
    out    = "<ul class='nav nav-tabs pull-right'>"
    out   +=   "<li class='active'>#{link_to 'General', '#tab_general', :data => {:toggle => 'tab'} }" if include_general
    Account.current.site_locales.each do |locale|
      active = "class='active'" if !include_general && Account.current.preferred_default_locale == locale
      out +=  "<li #{active}>#{link_to nls_flag_image(locale), '#tab_' + locale.to_s, :data => {:toggle => 'tab'} }</li>"
    end
    out   += "</ul>"
    out.html_safe
  end
  
  #------------------------------------------------------------------------------
  def nav_bar_items(item_array)
    out    = "<ul class='nav pull-right'>"
    item_array.each do |item|
      out += "<li>#{item}</li>"
    end
    out   += "</ul>"
    out.html_safe
  end
  
  # output a slim horizontal progress bar, with a label, value text, percentage, 
  # and color (such as info, success, pending, etc)
  #------------------------------------------------------------------------------
  def slim_progress_bar(options = {})
    #--- if no label specified, value will not get displayed properly
    options[:label] = '&nbsp;'.html_safe if (options[:label].blank? && options[:value])

    render(:partial => 'dm_core/admin/shared/slim_progress_bar', 
           :locals => { label: options[:label], 
                        value: options[:value].to_s,
                        color: (options[:color] || 'info'), 
                        percentage: options[:percentage].to_i,
                        bottom_label: options[:bottom_label]})
  end
  
  # Format flash messages for admin theme
  #------------------------------------------------------------------------------
  def flash_admin
    flash_class = {:notice => 'note-success', :error => 'note-danger', :alert => 'note-warning', :warning => 'note-warning', :info => 'note-info'}
    raw([:notice, :error, :alert, :warning, :info].collect {|type| content_tag('div', content_tag('div', flash[type], :class => "note #{flash_class[type]}"), :class => "notice outer") if flash[type] }.join)
  end
  
  #------------------------------------------------------------------------------
  def is_current_controller(controller_name)
    controller.controller_name == controller_name
  end

  # Check is a specific attribute of the theme is part of the name
  # Ex. If theme is 'lightgreen', then return true for theme_is?('light') or theme_is?('green')
  # Default theme is 'dark'
  #------------------------------------------------------------------------------
  def theme_is?(name)
    cookies[:theme].nil? || cookies[:theme].empty? ? 
        'dark'.include?(name) : cookies[:theme].include?(name)
  end
  
  # Return the path to the admin theme
  #------------------------------------------------------------------------------
  def admin_theme_path
    @admin_theme ||= '/admin/amsterdam/'
  end
  
  # use the value as an id on the body tag, to build css tweaks for the theme
  #------------------------------------------------------------------------------
  def admin_theme_id
    cookies[:theme].nil? || cookies[:theme].empty? ? 'dark' : cookies[:theme]    
  end
  
end
