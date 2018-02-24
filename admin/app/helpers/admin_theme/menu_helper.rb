module AdminTheme
  module MenuHelper
    #------------------------------------------------------------------------------
    def admin_top_menu
      menu = ''.html_safe
      @admin_theme[:top_menu].each do |item|
        if item[:children].nil?
          menu << content_tag(:li, link_to(menu_text(item), item[:link], item[:link_options]))
        else
          menu << content_tag(:li, class: 'dropdown') do
            link    = link_to (menu_text(item) + ' ' + icons(:caret_down)), '#', class: 'dropdown-toggle', data: { toggle: 'dropdown' }
            sub_ul  = ''.html_safe
            item[:children].each { |child| sub_ul << content_tag(:li, link_to(menu_text(child), child[:link], child[:link_options])) }
            link + content_tag(:ul, sub_ul, class: 'dropdown-menu dropdown-menu-right')
          end
        end
      end
      menu
    end

    #------------------------------------------------------------------------------
    def admin_main_menu
      menu = ''.html_safe
      menu_options = { badge_position: :right }
      @admin_theme[:main_menu].each do |item|
        item[:link_options] ||= {}
        if item[:children].nil?
          item[:link_options][:class] = item[:link_options][:class] ? item[:link_options][:class] + " #{item[:active]}" : item[:active]
          menu << content_tag(:li, link_to(menu_text(item, menu_options), item[:link], item[:link_options]))
        else
          #--- has submenu
          active  = false
          sub_ul  = ''.html_safe
          item[:children].each do |child|
            child[:link_options] ||= {}
            child[:link_options][:class] = child[:link_options][:class] ? child[:link_options][:class] + " #{item[:active]}" : child[:active]
            sub_ul << content_tag(:li, link_to(menu_text(child, menu_options), child[:link], child[:link_options]), class: child[:active])
            active ||= !child[:active].nil?
          end
          link    = link_to (menu_text(item, menu_options) + icons('fa arrow')), '#'
          menu_li = link + content_tag(:ul, sub_ul, class: 'nav nav-second-level')
          menu << content_tag(:li, menu_li, class: active ? 'active' : nil)
        end
      end
      menu
    end

    #------------------------------------------------------------------------------
    def menu_text(item, options = {})
      badge_class = item[:badge_class] || 'badge-primary'
      text = ''.html_safe
      text << (icons(item[:icon_class]) + ' ') if item[:icon_class]
      if item[:badge]
        if options[:badge_position] == :right
          text << content_tag(:span, item[:badge], class: "badge #{badge_class} pull-right")
        else
          text << content_tag(:span, item[:badge], class: "badge #{badge_class}")
        end
      end
      text << content_tag(:span, item[:text]) if item[:text]
      text
    end
  end
end
