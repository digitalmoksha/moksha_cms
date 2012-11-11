require 'devise'
require 'rolify'
require 'globalize3'
require 'easy_globalize3_accessors'
require 'country_select'
require 'simple_form'
require 'will_paginate'
require 'paper_trail'

module DmCore
  class Engine < ::Rails::Engine
    isolate_namespace DmCore
    
    initializer 'engine.helper' do |app|
      ActionView::Base.send :include, RenderHelper
      ActiveSupport.on_load(:action_controller) do
        include DmCore::ApplicationHelper
      end
    end
  end
end
