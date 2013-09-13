require 'ranked-model'
require 'money-rails'
require 'dm_core'
require 'activemerchant'

module DmEvent
  class Engine < ::Rails::Engine
    isolate_namespace DmEvent
  end
end
