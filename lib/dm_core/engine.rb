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
require 'kramdown'
require 'liquid'
require 'sanitize'
require 'acts_as_commentable'
require 'acts_as_votable'
require 'acts_as_follower'
require 'acts-as-taggable-on'
require 'ancestry'
require 'ranked-model'
require 'amoeba'
require 'babosa'
require 'friendly_id'
require 'aasm'
require 'monetize/core_extensions'
require 'money-rails'
require 'exception_notification'
require 'aws-sdk'
require 'biggs'
require 'codemirror-rails'
require 'mini_magick'
require 'carrierwave'

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
