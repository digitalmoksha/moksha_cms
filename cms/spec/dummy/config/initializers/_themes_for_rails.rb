# Make sure this loads before the account initialization
#------------------------------------------------------------------------------
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

#--- Load the theme config data
ThemesForRails.load_all_theme_data

#--- usually called in the ThemesForRails config.to_prepare method, 
#    for the precompile to work, these need to get called earlier than usual
if ENV['RAILS_GROUPS'] == 'assets'
  ThemesForRails.check_asset_pipeline
  ThemesForRails.add_themes_assets_to_asset_pipeline
end
