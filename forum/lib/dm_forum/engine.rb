require 'ranked-model'
require 'dm_core'
require 'dm_cms'
require 'themes_for_rails'

module DmForum
  class Engine < ::Rails::Engine
    isolate_namespace DmForum
  end
end
