require_relative 'lib/dm_core/version.rb'

#--- Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'dm_core'
  s.version     = DmCore::VERSION
  s.authors     = ['Brett Walker']
  s.email       = ['github@digitalmoksha.com']
  s.homepage    = 'https://github.com/digitalmoksha/moksha_cms'
  s.licenses    = ['MIT']
  s.summary     = 'Part of MokshaCms, providing core functionality'
  s.description = 'Part of MokshaCms, providing core functionality, including internationalization'

  s.files       = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files  = Dir['spec/**/*']

  #--- dont' forget to add 'require' statement in engine.rb
  s.add_dependency 'aasm', '~> 5.0'
  s.add_dependency 'actionview-encoded_mail_to', '~> 1.0'
  s.add_dependency 'activemerchant', '~> 1.107'
  s.add_dependency 'acts-as-taggable-on', '~> 6.5'
  s.add_dependency 'acts_as_commentable', '~> 4.0.2' # we customize our usage, so can't use the 'with_threading' version
  s.add_dependency 'acts_as_votable', '~> 0.12.1'
  s.add_dependency 'amoeba', '~> 3.1'             # TODO: (see if still needed) for handling model duplicating
  s.add_dependency 'ancestry', '~> 3.0'
  s.add_dependency 'aws-sdk-s3', '~> 1.64'
  s.add_dependency 'babosa', '~> 1.0'             # for better unicode slug handling with friendly_id
  s.add_dependency 'biggs', '~> 0.3.3'            # address formatting
  s.add_dependency 'cancancan', '~> 3.1'          # Authorization
  s.add_dependency 'carrierwave', '~> 2.1'
  s.add_dependency 'carrierwave-aws', '~> 1.5'
  s.add_dependency 'codemirror-rails', '~> 5.16'  # TODO: configure yarn and install codemirror from that
  s.add_dependency 'country_select', '~> 4.0'     # TODO: don't think needed any more.  Look into `countries` gem
  s.add_dependency 'daemons', '~> 1.3'
  s.add_dependency 'delayed_job', '~> 4.1'
  s.add_dependency 'delayed_job_active_record', '~> 4.1'
  s.add_dependency 'devise', '~> 4.7'             # Authentication
  s.add_dependency 'dm_preferences', '~> 1.5'
  s.add_dependency 'dm_ruby_extensions', '~> 1.0'
  s.add_dependency 'exception_notification'
  s.add_dependency 'friendly_id', '~> 5.3.0'
  s.add_dependency 'globalize', '~> 5.3'
  s.add_dependency 'highline', '~> 2.0'           # Necessary for the install generator
  s.add_dependency 'kramdown', '~> 2.2'
  s.add_dependency 'liquid', '~> 4.0'
  s.add_dependency 'mini_magick', '~> 4.10'
  s.add_dependency 'money-rails', '~> 1.13'
  s.add_dependency 'offsite_payments', '~> 2.7'   #--| of PaymentHistory model
  s.add_dependency 'paper_trail', '~> 10.3'       # table versioning
  s.add_dependency 'partisan', '~> 0.5'           # acts_as_follower clone
  s.add_dependency 'rails', '>= 4.2', '< 6.0'
  s.add_dependency 'rails-i18n', '>= 4.2', '< 6.0'
  s.add_dependency 'ranked-model', '~> 0.4.6'     # sort order for a list
  s.add_dependency 'recaptcha', '~> 5.5'
  s.add_dependency 'RedCloth', '~> 4.3'
  s.add_dependency 'rolify', '~> 5.2'             # User Roles
  s.add_dependency 'sanitize', '~> 5.1'
  s.add_dependency 'sentry-raven', '~> 3.0'
  s.add_dependency 'simple_form', '~> 5.0'        # Form handling
  s.add_dependency 'unicode'                      # needed for babosa
  s.add_dependency 'validates_email_format_of', '~> 1.6'
  s.add_dependency 'will_paginate', '~> 3.3'      # pagination
end
