module DmCore
  class ThemeInitialization
    def self.initialize_themes
      ThemesForRails.config do |config|
        # themes_dir is used to allow ThemesForRails to list available themes. It is not used to resolve any paths or routes.
        # config.themes_dir = ":root/app/assets/themes"
        config.themes_dir = ":root/themes"

        # themes_config_file is the yaml configuration file for a theme
        config.themes_config_file = ':root/themes/:name/_theme.yml'

        # assets_dir is the path to your theme assets.
        config.assets_dir = ':root/themes/:name/theme_assets'

        # views_dir is the path to your theme views
        config.views_dir = ':root/themes/:name/theme_support/views'

        # locales_dir is the path to your theme locales
        config.locales_dir = ':root/themes/:name/theme_support/locales'

        # themes_routes_dir is the asset pipeline route base.
        # Because of the way the asset pipeline resolves paths, you do
        # not need to include the 'themes' folder in your route dir.
        #
        # for example, to get application.css for the default theme,
        # your URL route should be : /assets/default/stylesheets/application.css
        config.themes_routes_dir = "assets"

        config.asset_digests_enabled = true
      end
    end

    # load themes, including Liquid tags, locales, etc
    #------------------------------------------------------------------------------
    def self.load_themes
      #--- Load the theme config data
      ThemesForRails.load_all_theme_data

      #--- usually called in the ThemesForRails config.to_prepare method,
      #    for the precompile to work, these need to get called earlier than usual
      if ENV['RAILS_GROUPS'] == 'assets'
        ThemesForRails.check_asset_pipeline
        ThemesForRails.add_themes_assets_to_asset_pipeline
      end

      # Register the Liquid tags for each theme.  Since tags are in the global
      # Liquid namespace, we need to namespace them per theme, based on the
      # account identifier
      ThemesForRails.available_theme_names.each do |theme_name|
        theme_data        = ThemesForRails.config.theme_data[theme_name]
        theme_root        = Rails.root.join('themes', theme_name)

        unless ENV['RAILS_GROUPS'] == 'assets'
          # Load models from themes
          Dir.glob(File.join(theme_root, "/theme_support/models/*.rb")).sort.each do |path|
            require path
          end

          # Load helpers from themes
          Dir.glob(File.join(theme_root, "/theme_support/helpers/*.rb")).sort.each do |path|
            require path
          end

          # Register tags from themes
          Dir.glob(File.join(theme_root, "/theme_support/tags/*.rb")).sort.each do |path|
            require path
            file = path.split('/').last.split('.').first
            ::Liquid::Template.register_tag_namespace(file, "Liquid::Theme#{theme_name.camelize}::#{file.camelize}".constantize, theme_name)
          end
        end

        # add items listed in theme.yml to be pre-compiled in asset pipeline
        if Rails.env.development? || Rails.env.production? || Rails.env.staging?
          if theme_data && theme_data['precompile']
            Rails.application.config.assets.precompile << theme_data['precompile']
          end
        end
      end
    end
  end
end
