require 'dm_core'
# require 'spree'
require 'spree_core'
require 'spree_backend'
# require 'spree_gateway'

module DmSpree
  class Engine < ::Rails::Engine
    isolate_namespace DmSpree

    config.to_prepare do
      require_dependency 'dm_spree/model_decorators'
    end
    
    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
