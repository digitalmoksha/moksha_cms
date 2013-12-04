require 'ranked-model'
require 'money-rails'
require 'dm_core'
require 'activemerchant'

module DmEvent
  class Engine < ::Rails::Engine
    isolate_namespace DmEvent

    config.to_prepare do
      require_dependency 'dm_event/model_decorators'
    end
  end
end

