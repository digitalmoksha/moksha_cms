require 'ranked-model'
require 'dm_core'
require 'dm_cms'

module DmEvent
  class Engine < ::Rails::Engine
    isolate_namespace DmEvent
  end
end
