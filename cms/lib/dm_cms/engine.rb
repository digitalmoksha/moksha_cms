require 'meta-tags-helpers'
require 'mail_form'
require 'dm_core'

module DmCms
  class Engine < ::Rails::Engine
    isolate_namespace DmCms
    
    initializer "dm_cms.init_liquid_tags" do |app|
      #--- require each tag -- registration is done in the tag file itself
      Dir.glob(File.expand_path("../../../app/liquid/tags/*.rb", __FILE__)).each do |path|
        require path
      end
    end
  end
end
