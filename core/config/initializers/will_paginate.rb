# config/initializers/will_paginate.rb
# 
# This extension code was written by Isaac Bowen, originally found
# at http://isaacbowen.com/blog/using-will_paginate-action_view-and-bootstrap/

require 'will_paginate/view_helpers/action_view'

module WillPaginate
  module ActionView
    def will_paginate(collection = nil, options = {})
      options, collection = collection, nil if collection.is_a? Hash
      collection                ||= infer_collection_from_controller 
      
      options[:version]         ||= :original
      case options.delete(:version)
      when :bootstrap2
        options[:renderer]      ||= Bootstrap2LinkRenderer
      when :bootstrap3
        options[:renderer]      ||= Bootstrap3LinkRenderer
      else
        options[:renderer]      ||= OriginalLinkRenderer
        options[:class]         ||= 'tPages'
      end
      
      options[:previous_label]  ||= '<i class="fa fa-arrow-left"></i>'
      options[:next_label]      ||= '<i class="fa fa-arrow-right"></i>'
      super.try :html_safe
    end

    # The original renderer
    #------------------------------------------------------------------------------
    class OriginalLinkRenderer < LinkRenderer
      protected
    
      def html_container(html)
        tag :div, tag(:ul, html, class: 'pages'), container_attributes
      end

      def page_number(page)
        tag :li, link(page, page, rel: rel_value(page), class: ('active' if page == current_page))
      end

      def gap
        tag :li, link('&hellip;'.html_safe, '#'), class: 'disabled'
      end

      def previous_or_next_page(page, text, classname)
        tag :li, link(text, page || '#'),
            class: [(classname[0..3] if  @options[:page_links]), (classname if @options[:page_links]), ('disabled' unless page)].join(' ')
      end
    end

    # Bootstrap2 version
    #------------------------------------------------------------------------------
    class Bootstrap2LinkRenderer < LinkRenderer
      protected
    
      def html_container(html)
        tag :div, tag(:ul, html), container_attributes
      end

      def page_number(page)
        tag :li, link(page, page, rel: rel_value(page)), class: ('active' if page == current_page)
      end

      def gap
        tag :li, link(super, '#'), class: 'disabled'
      end

      def previous_or_next_page(page, text, classname)
        tag :li, link(text, page || '#'), class: [classname[0..3], classname, ('disabled' unless page)].join(' ')
      end
    end

    # Bootstrap3 version
    #------------------------------------------------------------------------------
    class Bootstrap3LinkRenderer < Bootstrap2LinkRenderer
      protected
    
      def html_container(html)
        tag :ul, html, container_attributes
      end

    end

  end
end