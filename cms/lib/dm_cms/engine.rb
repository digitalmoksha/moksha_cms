require 'ancestry'
require 'acts_as_list'
require 'dm_core'

module DmCms
  class Engine < ::Rails::Engine
    isolate_namespace DmCms
  end
end
