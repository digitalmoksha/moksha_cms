require 'ancestry'
require 'meta-tags-helpers'
require 'mail_form'
require 'dm_core'

module DmCms
  class Engine < ::Rails::Engine
    isolate_namespace DmCms
  end
end
