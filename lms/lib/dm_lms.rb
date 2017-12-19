require "dm_lms/engine"

module DmLms

  # configuration values are hung off of the Rails.application.config
  # object and can be accessed as either `DmLms.config.valuename` or
  # `Rails.application.config.dm_lms.valuename`
  #------------------------------------------------------------------------------
  def self.config
    Rails.application.config.dm_lms
  end

  #------------------------------------------------------------------------------
  def self.configure
    yield(Rails.application.config.dm_lms) if block_given?
    Rails.application.config.dm_lms
  end

  #------------------------------------------------------------------------------
  def self.initialize_configuration
    Rails.application.config.dm_lms = ActiveSupport::OrderedOptions.new
    DmLms.configure do |config|
      config.use_markdown = true    # if false, Textile is used
    end
  end

end
