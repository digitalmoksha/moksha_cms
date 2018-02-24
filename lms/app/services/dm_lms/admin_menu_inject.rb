module DmLms
  class AdminMenuInject
    #------------------------------------------------------------------------------
    def self.menu_items(user)
      menu = []
      menu << { text: 'Courses', icon_class: :courses, link: DmLms::Engine.routes.url_helpers.admin_courses_path(locale: I18n.locale) } if user.can?(:manage_coursed, :all)
      menu
    end
  end
end
