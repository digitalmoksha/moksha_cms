require 'dm_core'

# TODO this is a hack for DmLms::Admin::CoursesController
# `course_params` for some reason was not being found/loaded,
# even with the correct line `include DmLms::PermittedParams`.
# One app works without it, another one doesn't.  So for now, make
# sure `permitted_params` is loaded
require_relative '../../app/models/dm_lms/permitted_params'

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
