# Perform any specific account initialization such as loading Liquid tags, locales, etc
#------------------------------------------------------------------------------

Rails.logger.info "=== Account Initializer"

# Register the Liquid tags for each theme.  Since tags are in the global
# Liquid namespace, we need to namespace them per theme, based on the
# account identifier
ThemesForRails.available_theme_names.each do |theme_name|
  theme_data        = ThemesForRails.config.theme_data[theme_name]
  theme_root        = Rails.root.join('themes', theme_name)

  unless ENV['RAILS_GROUPS'] == 'assets'
    # Load models from themes
    Dir.glob(File.join(theme_root, "/theme_support/models/*.rb")).each do |path|
      require path
    end

    # Load helpers from themes
    Dir.glob(File.join(theme_root, "/theme_support/helpers/*.rb")).each do |path|
      require path
    end

    # Register tags from themes
    Dir.glob(File.join(theme_root, "/theme_support/tags/*.rb")).each do |path|
      require path
      file = path.split('/').last.split('.').first
      Liquid::Template.register_tag_namespace(file, "Liquid::Theme#{theme_name.camelize}::#{file.camelize}".constantize, theme_name)
    end
  end

  # add items listed in theme.yml to be pre-compiled in asset pipeline
  if Rails.env.production? || Rails.env.staging? || Rails.env.development?
    if theme_data and theme_data['precompile']
      Rails.application.config.assets.precompile += theme_data['precompile']
    end
  end
end
