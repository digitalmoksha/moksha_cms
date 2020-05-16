require 'font-awesome-rails'
require 'dm_core'

module DmAdmin
  class Engine < ::Rails::Engine
    isolate_namespace DmAdmin

    initializer 'engine.assets.precompile' do |app|
      app.config.assets.precompile += %w[dm_admin/manifest.js]
    end
  end
end
