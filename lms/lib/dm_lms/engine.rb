require 'dm_core'

module DmLms
  class Engine < ::Rails::Engine
    isolate_namespace DmLms

    config.to_prepare do
      require_dependency 'dm_lms/model_decorators'
    end

    config.before_initialize do
      DmLms.initialize_configuration
    end
  end

  # Add any specific files that need to be precompiled seperately for the asset pipeline
  #-------------------------------------------------------------------------------------
  class Railtie < Rails::Railtie
    initializer :lms_precompile, :group => :assets do |app|
      # app.config.assets.precompile += %w( dm_lms/practice_sheet.css )
    end
  end
end
