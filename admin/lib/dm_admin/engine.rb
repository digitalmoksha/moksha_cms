require "font-awesome-rails"
require 'dm_core'

module DmAdmin
  class Engine < ::Rails::Engine
    isolate_namespace DmAdmin
    initializer 'DmAdmin.assets_pipeline' do |app|
      app.config.assets.precompile += ['admin_theme/theme.css', 'admin_theme/theme.js']
    end
  end
end
