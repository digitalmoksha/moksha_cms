require 'dm_core'
require 'gibbon'

module DmNewsletter
  class Engine < ::Rails::Engine
    isolate_namespace DmNewsletter
  end
end
