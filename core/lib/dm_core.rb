require "dm_core/engine"
require "dm_core/nls"
require "dm_core/state_select"
require 'dm_core/liquid_extensions'

include Nls

module DmCore
  
  #------------------------------------------------------------------------------
  class << self
    attr_accessor :config
  end
  
  #------------------------------------------------------------------------------
  def self.configure
    self.config ||= Configuration.new
    yield(config)
  end
  
  #------------------------------------------------------------------------------
  class Configuration
    attr_accessor :default_locale
    attr_accessor :locales
    attr_accessor :enable_themes  # enable using themes_for_rails gem
    
    #------------------------------------------------------------------------------
    def initialize
      @locales        = [ :en ]
      @default_locale = :en
      @enable_themes  = false
    end
  end
end
