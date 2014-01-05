require 'csv'

require 'devise'
require 'rolify'
require 'cancan'
require 'globalize'
require 'country_select'
require 'simple_form'
require 'will_paginate'
require 'paper_trail'
require 'RedCloth'
require 'bluecloth'
require 'kramdown'
require 'liquid'
require 'acts_as_commentable'
require 'acts_as_votable'
require 'ancestry'
require 'ranked-model'
require 'amoeba'
require 'babosa'
require 'friendly_id'
require 'aasm'
require 'money-rails'
require 'exception_notification'

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
