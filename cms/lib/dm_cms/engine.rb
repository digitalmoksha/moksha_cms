require 'meta-tags-helpers'
require 'mail_form'
require 'dm_core'

module DmCms
  class Engine < ::Rails::Engine
    isolate_namespace DmCms

    config.to_prepare do
      require_dependency 'dm_cms/model_decorators'
    end

    initializer "dm_cms.init_liquid_tags" do |app|
      #--- require each tag -- registration is done in the tag file itself, so they can't be autoloaded
      Dir.glob(File.expand_path("../../../app/liquid/tags/*.rb", __FILE__)).sort.each do |path|
        require path
      end
      Dir.glob(File.expand_path("../../../app/liquid/filters/*.rb", __FILE__)).sort.each do |path|
        require path
      end
    end
  end
end
