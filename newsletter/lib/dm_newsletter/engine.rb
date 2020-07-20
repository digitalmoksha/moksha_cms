require 'dm_core'
require 'gibbon'

module DmNewsletter
  class Engine < ::Rails::Engine
    isolate_namespace DmNewsletter

    config.to_prepare do
      require_dependency 'dm_newsletter/model_decorators'
    end

    initializer 'engine.assets.precompile' do |app|
      app.config.assets.precompile += %w[dm_newsletter/manifest.js]
    end
  end
end
