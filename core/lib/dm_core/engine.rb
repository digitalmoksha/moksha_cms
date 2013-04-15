require 'devise'
require 'rolify'
require 'cancan'
require 'globalize3'
require 'easy_globalize3_accessors'
require 'country_select'
require 'simple_form'
require 'will_paginate'
require 'paper_trail'
require 'RedCloth'
require 'bluecloth'
require 'liquid'
require 'acts_as_commentable'
require 'amoeba'
require 'friendly_id'

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
