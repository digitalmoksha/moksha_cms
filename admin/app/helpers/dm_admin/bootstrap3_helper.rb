# Bootstrap 3 helper functions
#------------------------------------------------------------------------------
module DmAdmin::Bootstrap3Helper
  # Panel: outputs a panel structure
  #   body:     set to false to not wrap in a panel-body class
  #   id:       an id for the panel
  #   class:    any extra classes for panel
  #   title:    text to display in panel heading
  #   toolbar:  toolbar html (button groups, etc) to place in the header, pulled right
  #------------------------------------------------------------------------------
  def panel(options = {}, &block)
    options[:id]            ||= ''
    options[:class]         ||= 'panel-default'

    content = with_output_buffer(&block)
    content_tag :div, id: options[:id], class: "panel #{options[:class]}" do
      concat(panel_heading(options)) unless options[:header] == false
      options[:body] == false ? concat(content) : concat(content_tag(:div, content, class: 'panel-body'))
    end
  end

  # Panel heading
  #------------------------------------------------------------------------------
  def panel_heading(options = {})
    options[:title]         ||= ''
    options[:toolbar]       ||= ''
    options[:title_small]   ||= true

    title = options[:title] + (options[:subtitle].blank? ? '' : content_tag(:small, options[:subtitle]))
    content_tag(:div, class: 'panel-heading') do
      if options[:title_small]
        concat(content_tag(:span, title))
      else
        concat(content_tag(:h3, title, class: 'panel-title'))
      end
      concat(content_tag(:div, options[:toolbar], class: 'panel_toolbar pull-right')) if options[:toolbar].present?
    end
  end

  #------------------------------------------------------------------------------
  def panel_body(options = {}, &block)
    content = with_output_buffer(&block)
    content_tag(:div, content, class: 'panel-body')
  end

  #------------------------------------------------------------------------------
  def page_header(options = {}, &block)
    content   = block_given? ? capture(&block) : ''
    sub_title = options[:subtitle].present? ? content_tag(:small, options[:subtitle]) : ''

    content_tag(:div, class: 'page-header') do
      concat(content)
      concat(content_tag(:h3, "#{options[:title]} #{sub_title}".html_safe))
    end
  end

  #------------------------------------------------------------------------------
  def page_header_buttons(options = {}, &block)
    content = capture(&block)

    buttons = content_tag(:div, class: 'header-buttons pull-right') do
      content_tag(:div, id: 'header-buttons') do
        content_tag(:div) do
          content
        end
      end
    end
    buttons
  end

  # Displays a "well" with content, flush to the edges.  Optional title and explanation
  # text
  #------------------------------------------------------------------------------
  def well(options = {}, &block)
    options[:title]         ||= ''
    options[:id]            ||= ''
    options[:class]         ||= ''
    options[:explanation]   ||= ''
    class_options             = "well " + options[:class]

    content = with_output_buffer(&block)
    content_tag :div do
      concat(content_tag(:span, options[:title], class: 'subtitle')) unless options[:title].blank?
      concat(content_tag(:p, options[:explanation], class: 'explanation')) unless options[:explanation].blank?
      concat(content_tag(:div, content, class: class_options, id: options[:id]))
    end
  end

  # quick way to generate a button for placement in a panel toolbar
  #------------------------------------------------------------------------------
  def toolbar_btn(label, url, options = {})
    options[:class] ||= 'btn btn-xs btn-info'
    link_to(label, url, options)
  end

  # Format flash messages for admin theme
  #------------------------------------------------------------------------------
  def flash_admin
    flash_class = { notice: 'alert-success', error: 'alert-danger', alert: 'alert-warning', warning: 'alert-warning', info: 'alert-info' }
    msgs = [:notice, :error, :alert, :warning, :info].collect do |type|
      next unless flash[type]

      content_tag 'div', class: "alert alert-dismissable #{flash_class[type]}" do
        content_tag(:button, 'x', class: 'close', data: { dismiss: 'alert' }) + flash[type]
      end
    end
    raw(msgs.join)
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
    options[:delete]        = 'Delete' if options[:delete].blank? && options[:delete_url]

    content_tag :div, class: 'form-action text-right' do
      #--- check if we want a delete button
      concat(link_to(options[:delete], options[:delete_url], method: :delete, class: 'btn btn-sm btn-danger pull-left', data: { confirm: options[:delete_confirm] })) if options[:delete_url]
      #--- check if we want a cancel button
      if options[:cancel] != false
        if options[:cancel_url].blank?
          #--- if no url specified, assume sliding the div closed
          concat(link_to(options[:cancel], '#', class: 'toggle_link btn', data: { toggleid: options[:slide] }))
        elsif options[:cancel_url] == 'close-modal'
          concat(link_to(options[:cancel], '#', class: 'btn btn-sm btn-default', data: { dismiss: 'modal' }))
        else
          concat(link_to(options[:cancel], options[:cancel_url], { class: 'btn btn-sm btn-default' }))
        end
        concat(content_tag(:span, '&nbsp;&nbsp;&nbsp;&nbsp;'.html_safe, class: 'submit_or'))
      end
      concat(submit_tag(options[:save], class: 'btn btn-sm btn-primary'))
    end
  end

  # Helper for using the Font Awesome or Bootstrap icons
  # params:
  #   icon_class => name of the class for the icon ie. font-camera for Font Awesome
  #                 or icon-camera for Bootstrap
  #   :size      => such as 32, gives a font size of 32px
  #   :color     => sets the color of the icon
  #   anything else gets passed as html options to the tag
  #------------------------------------------------------------------------------
  def icons(icon_class, options = {})
    options[:class] = (::COMMON_ICONS[icon_class] || icon_class)
    options[:class] = "#{options[:class]} #{options[:icon_class]}" if options[:icon_class]
    options[:style] = "#{options[:style]} font-size:#{options[:size]}px;" unless options[:size].blank?
    options[:style] = "#{options[:style]} color:#{options[:color]}" unless options[:color].blank?

    content_tag(:i, '', options)
  end

  # Generate icon followed by label text
  # Note: span around text is needed for some css
  #------------------------------------------------------------------------------
  def icon_label(icon_type, text, options = {})
    icons(icon_type, options) + ' ' + content_tag(:span, text, class: options[:label_class])
  end

  # Generate label text followed by an icon
  # Note: span around text is needed for some css
  #------------------------------------------------------------------------------
  def label_icon(text, icon_type, options = {})
    content_tag(:span, text, class: options[:label_class]) + ' ' + icons(icon_type, options)
  end

  # A tabbed frame with locales as the tabs
  #------------------------------------------------------------------------------
  def locale_tabs(options = {}, &block)
    options[:title]         ||= ''
    options[:id]            ||= "locale_pane_#{rand(1000)}"
    options[:class]         ||= ''

    content = {}
    current_account.site_locales.each do |locale|
      content[locale] = capture(locale, &block)
    end
    render partial: 'dm_admin/shared/locale_tabs', locals: { options: options, content: content }
  end

  # A colored text label.
  # style => :success, :important, :info, :warning, inverse
  #------------------------------------------------------------------------------
  def colored_label(text, style = :plain)
    if style == :plain
      content_tag :span, text, class: 'label label-default'
    else
      content_tag :span, text, class: "label label-#{style}"
    end
  end

  # A colored text badge.
  # style => :success, :important, :info, :warning, inverse
  #------------------------------------------------------------------------------
  def colored_badge(text, style = :plain)
    if style == :plain
      content_tag :span, text, class: 'badge'
    else
      content_tag :span, text, class: "badge label-#{style}"
    end
  end

  # Similar to a content_box, but don't wrap the content in a div "body" tag, which has
  # margins/padding.  Useful for forms and tables
  #------------------------------------------------------------------------------
  def modal_dialog(options = {}, &block)
    options[:title]         ||= ''
    options[:id]            ||= ''
    options[:include_save]    = options[:include_save].nil? ? false : options[:include_save]
    options[:delete_url]    ||= nil
    options[:delete_msg]    ||= 'Are you sure you want to DELETE this?'

    content = with_output_buffer(&block)
    render partial: 'dm_admin/shared/modal_dialog', locals: { options: options, content: content }
  end
end
