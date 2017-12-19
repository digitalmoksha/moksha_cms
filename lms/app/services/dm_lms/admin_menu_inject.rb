module DmLms
  class AdminMenuInject

    #------------------------------------------------------------------------------
    def self.menu_items(user)
      menu = []
      if user.can?(:manage_coursed, :all)
        menu << { text: 'Courses', icon_class: :courses, link: DmLms::Engine.routes.url_helpers.admin_courses_path(locale: I18n.locale) }
      end
      return menu
    end

  end
end