require 'csv'

require 'rails-i18n'
require 'preferences'
require 'devise'
require 'recaptcha/rails'
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
require 'partisan'
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
require 'aws-sdk-s3'
require 'biggs'
require 'codemirror-rails'
require 'mini_magick'
require 'carrierwave'
require 'carrierwave-aws'
require 'validates_email_format_of'
require 'activemerchant'
require 'active_merchant/billing/rails'
require 'offsite_payments'
require 'delayed_job_active_record'
require 'delayed_job'
require 'sentry-raven'

module DmCore
  class Engine < ::Rails::Engine
    isolate_namespace DmCore

    initializer 'engine.helper' do |app|
      ActionView::Base.include RenderHelper
      ActiveSupport.on_load(:action_controller) do
        include DmCore::ApplicationHelper
      end
    end

    initializer 'engine.assets.precompile' do |app|
      app.config.assets.precompile += %w[dm_core/manifest.js]
    end

    config.before_initialize do
      # make sure the ability.rb file is loaded initially - this was a problem when running specs
      require File.expand_path("../../../app/models/ability.rb", __FILE__)
      DmCore.initialize_configuration
    end
  end
end
