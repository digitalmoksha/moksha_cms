# Helper methods for virtualizing aspects of the Aquincum Theme
# The render_admin helper also contains some functions as well
#------------------------------------------------------------------------------
module Admin::ThemeAquincumHelper

  ICONB_CODES = { :edit => '&#xe1db;',      :delete => '&#xe136;',
                  :pages => '&#xe015;',     :view => '&#xe271;',
                  :trash => '&#xe158;',     :edit_2 => '&#xe003;',
                  :dashboard => '&#xe028;', :lexicon => '&#xe011;',
                  :users => '&#xe1e1;',     :play => '&#xe009;'}

  # generate the html for using the icos icons
  #------------------------------------------------------------------------------
  def icos_text(text, icos = '')
    "<span class='#{icos}'></span>#{text}".html_safe
  end
  
  # params:
  #   icon_type => can use either the mnemoic name or the character code
  #   :size     => such as 32, gives a font size of 32px
  #------------------------------------------------------------------------------
  def iconb(icon_type, options = {})
    style     = (options[:size].blank? ? '' : "style='font-size:#{options[:size]}px;'")
    icon_type = (ICONB_CODES[icon_type].blank? ? icon_type : ICONB_CODES[icon_type])
    
    "<span class='iconb' data-icon='#{icon_type}' #{style}></span>".html_safe
  end

  #------------------------------------------------------------------------------
  def content_box(options = {}, &block)
    options[:title]   ||= ''
    options[:id]      ||= ''
    options[:class]   ||= ''
    options[:toolbar] ||= ''
    
    content = with_output_buffer(&block)
    content_tag :div, :id => options[:id], :class => "widget fluid #{options[:class]}" do
      "<div class='whead'><h6>#{options[:title]}</h6>#{options[:toolbar]}<div class='clear'></div></div>".html_safe +
      content_tag(:div, content, :class => 'body')
    end
  end

  # Similar to a content_box, but don't wrap the content in a div "body" tag, which has
  # margins/padding.  Useful for forms and tables
  #------------------------------------------------------------------------------
  def content_frame(options = {}, &block)
    options[:title]   ||= ''
    options[:id]      ||= ''
    options[:class]   ||= ''
    options[:toolbar] ||= ''

    if options[:toolbar] == :languages
      options[:toolbar] = language_toolbar_tabs
      options[:class] += ' rightTabs'
    end
    
    content = with_output_buffer(&block)
    content_tag :div, :id => options[:id], :class => "widget fluid #{options[:class]}" do
      "<div class='whead'><h6>#{options[:title]}</h6>#{options[:toolbar]}<div class='clear'></div></div>".html_safe +
      content
    end
  end

  # Form row
  #------------------------------------------------------------------------------
  def form_row(options = {}, &block)
    options[:label]      ||= ''
    options[:for]        ||= ''
    options[:hint]       ||= ''
    options[:submit]     ||= false
    
    content              = with_output_buffer(&block)
    
    render :partial => 'dm_core/admin/shared/form_row', :locals => { :options => options, :content => content }
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

    out =  "<div class='formRow'><div class='formSubmit'>"
    out << "#{submit_tag options[:save], :class => 'buttonM bBlue'}"

    #--- check if we want a cancel button
    if options[:cancel] != false
      out << "<span class='submit_or'>&nbsp;&nbsp;&nbsp;&nbsp;</span>"
      if options[:cancel_url].blank?
        #--- if no url specified, assume sliding the div closed
        out << "#{link_to options[:cancel], '#', :class => 'toggle_link buttonM bDefault', :data => { :toggleid => options[:slide] } }"
      else
        out << "#{link_to options[:cancel], options[:cancel_url], {:class => 'buttonM bDefault'} }"
      end
    end
    
    #--- add the indicator
    #out << "#{image_tag_plugin('indicator_small.gif', :id => options[:indicator], :style => 'padding-left:10px;display:none;border:none;')}"
    out << "<div class='clear'></div></div><div class='clear'></div></div>"
    return out.html_safe
  end
  
  #------------------------------------------------------------------------------
  def language_toolbar_tabs(include_general = true)
    out    = "<ul class='tabs toolbar'>"
    out   +=   "<li>#{link_to 'General', '#tab_general'}" if include_general
    DmCore::Language.language_array.each do |locale|
      out +=  "<li>#{link_to nls_flag_image(locale), '#tab_' + locale.to_s, :class => 'headIcon'}</li>"
    end
    out   += "</ul>"
    out.html_safe
  end
  
  # Format flash messages for admin theme
  #------------------------------------------------------------------------------
  def flash_admin
    flash_class = {:notice => 'nSuccess', :error => 'nFailure', :alert => 'nWarning', :warning => 'nWarning', :info => 'nInformation'}
    raw([:notice, :error, :alert].collect {|type| content_tag('div', content_tag('p', flash[type]), :class => "nNote #{flash_class[type]}") if flash[type] }.join)
  end
  
  #------------------------------------------------------------------------------
  def is_current_controller(controller_name)
    controller.controller_name == controller_name
  end
end
