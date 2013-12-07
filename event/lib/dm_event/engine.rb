require 'ranked-model'
require 'money-rails'
require 'dm_core'
require 'activemerchant'
require 'mini_magick'
require 'carrierwave'

module DmEvent
  class Engine < ::Rails::Engine
    isolate_namespace DmEvent

    config.to_prepare do
      require_dependency 'dm_event/model_decorators'
    end
    
    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
    
  end
end