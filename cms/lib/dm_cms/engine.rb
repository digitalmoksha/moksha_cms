require 'meta-tags-helpers'
require 'mail_form'
require 'dm_core'

module DmCms
  class Engine < ::Rails::Engine
    isolate_namespace DmCms

    config.to_prepare do
      require_dependency 'dm_cms/model_decorators'
    end

    initializer 'engine.assets.precompile' do |app|
      app.config.assets.precompile += %w[dm_cms/manifest.js]
    end
  end
end
