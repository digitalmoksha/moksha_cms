require 'dm_core'
require 'dm_cms'
require 'themes_for_rails'

module DmForum
  class Engine < ::Rails::Engine
    isolate_namespace DmForum

    config.to_prepare do
      require_dependency 'dm_forum/model_decorators'
    end

    initializer 'engine.assets.precompile' do |app|
      app.config.assets.precompile += %w[dm_forum/manifest.js]
    end
  end
end
