require 'ranked-model'
require 'money-rails'
require 'dm_core'

module DmEvent
  class Engine < ::Rails::Engine
    isolate_namespace DmEvent
  end
end
