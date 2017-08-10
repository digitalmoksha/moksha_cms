module DmForum
  class AdminMenuInject
        
    #------------------------------------------------------------------------------
    def self.menu_items(user)
      menu = []
      if user.can?(:manage_forums, :all)
        menu << {text: 'Forums', icon_class: :forums, link: DmForum::Engine.routes.url_helpers.admin_forum_categories_path(locale: I18n.locale),
                 active_links: [DmForum::Engine.routes.url_helpers.admin_forum_categories_path(locale: I18n.locale),
                                DmForum::Engine.routes.url_helpers.admin_forums_path(locale: I18n.locale)
                               ] }
      end
      return menu
    end

  end
end