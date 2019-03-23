require 'dm_ruby_extensions'
require 'dm_preferences'
require 'dm_core/engine'
require 'dm_core/nls'
require 'dm_core/state_select'
require 'dm_core/liquid_extensions'
require 'dm_core/csv_exporter'
require 'dm_core/csv_importer'
require 'dm_core/theme_initialization'

include Nls

module DmCore
  APP_DIRS_PATTERN = %r{\/?(app|config|lib|spec|themes|\(\w*\))}

  # DmCore configuration values are hung off of the Rails.application.config
  # object and can be accessed as either `DmCore.config.valuename` or
  # `Rails.application.config.dm_core.valuename`
  #------------------------------------------------------------------------------
  def self.config
    Rails.application.config.dm_core
  end

  #------------------------------------------------------------------------------
  def self.configure
    yield(Rails.application.config.dm_core) if block_given?
    Rails.application.config.dm_core
  end

  #------------------------------------------------------------------------------
  def self.initialize_configuration
    Rails.application.config.dm_core = ActiveSupport::OrderedOptions.new
    DmCore.configure do |config|
      config.locales        = [:en]
      config.default_locale = :en
      config.enable_themes  = false
    end
  end
end
