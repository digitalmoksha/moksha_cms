module DmEvent
  class AdminMenuInject
    #------------------------------------------------------------------------------
    def self.menu_items(user)
      menu = []
      if user.can?(:access_event_section, :all)
        item = { text: 'Events', icon_class: :events, children: [], link: '#' }
        item[:children] << { text: 'Overview', link: DmEvent::Engine.routes.url_helpers.admin_workshops_path(locale: I18n.locale) }
        Workshop.upcoming.each do |workshop|
          if user.can?(:list_events, workshop)
            item[:children] << { text: workshop.title,
                                 badge: workshop.registrations.number_of(:attending),
                                 badge_class: 'badge-menu',
                                 link: DmEvent::Engine.routes.url_helpers.admin_workshop_path(locale: I18n.locale, id: workshop.id) }
          end
        end
        menu << item
      end

      return menu
    end
  end
end
