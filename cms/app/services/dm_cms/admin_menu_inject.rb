module DmCms
  class AdminMenuInject
    #------------------------------------------------------------------------------
    def self.menu_items(user)
      menu = []
      if user.can?(:access_content_section, :all)
        menu << {text: 'Pages', icon_class: :pages, link: DmCms::Engine.routes.url_helpers.admin_cms_pages_path(locale: I18n.locale),
                 active_links: [DmCms::Engine.routes.url_helpers.admin_cms_pages_path(locale: I18n.locale),
                                DmCms::Engine.routes.url_helpers.admin_cms_snippets_path(locale: I18n.locale)
                              ] }
        menu << {text: 'Blogs', icon_class: :blogs, link: DmCms::Engine.routes.url_helpers.admin_cms_blogs_path(locale: I18n.locale) }
      end

      if user.can?(:access_media_library, :all)
        menu << {text: 'Media Library', icon_class: :media_library, link: DmCms::Engine.routes.url_helpers.admin_media_files_path(locale: I18n.locale) }
      end
      return menu
    end
  end
end