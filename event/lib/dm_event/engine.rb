require 'dm_core'

module DmEvent
  class Engine < ::Rails::Engine
    isolate_namespace DmEvent

    config.to_prepare do
      require_dependency 'dm_event/model_decorators'
    end

    config.generators do |g|
      g.test_framework      :rspec,       fixture: false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.assets false
      g.helper false
    end

    initializer 'engine.assets.precompile' do |app|
      app.config.assets.precompile += %w[dm_event/manifest.js]
    end
  end
end
