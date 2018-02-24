module DmNewsletter
  class AdminMenuInject
    #------------------------------------------------------------------------------
    def self.menu_items(user)
      menu = []
      menu << { text: 'Newsletter', icon_class: :newsletters, link: DmNewsletter::Engine.routes.url_helpers.admin_newsletters_path(locale: I18n.locale) } if user.can?(:manage_newsletters, :all)
      menu
    end
  end
end
