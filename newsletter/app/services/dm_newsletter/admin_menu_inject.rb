module DmNewsletter
  class AdminMenuInject
        
    #------------------------------------------------------------------------------
    def self.menu_items(user)
      menu = []
      if user.can?(:manage_newsletters, :all)
        menu << {text: 'Newsletter', icon_class: :newsletters, link: DmNewsletter::Engine.routes.url_helpers.admin_newsletters_path(locale: I18n.locale) }
      end
      return menu
    end

  end
end