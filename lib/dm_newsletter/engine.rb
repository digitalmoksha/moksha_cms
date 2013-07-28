require 'dm_core'

module DmNewsletter
  class Engine < ::Rails::Engine
    isolate_namespace DmNewsletter
  end
end
