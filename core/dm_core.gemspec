require_relative 'lib/dm_core/version.rb'

#--- Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dm_core"
  s.version     = DmCore::VERSION
  s.authors     = ["Brett Walker"]
  s.email       = ["github@digitalmoksha.com"]
  s.homepage    = "https://github.com/digitalmoksha/moksha_cms"
  s.licenses    = ['MIT']
  s.summary     = "Part of MokshaCms, providing core functionality"
  s.description = "Part of MokshaCms, providing core functionality, including internationalization"

  s.files       = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files  = Dir["spec/**/*"]

  #--- dont' forget to add 'require' statement in engine.rb
  s.add_dependency 'rails', '>= 4.2', '< 5.1'
  s.add_dependency 'dm_ruby_extensions', '~> 1.0'
  s.add_dependency 'dm_preferences', '~> 1.5'
  s.add_dependency 'actionview-encoded_mail_to', '~> 1.0'
  s.add_dependency 'devise', '~> 4.2'           # Authentication
  s.add_dependency 'validates_email_format_of'
  s.add_dependency "cancancan", "~> 1.13"         # Authorization
  s.add_dependency "simple_form", '~> 3.2'        # Form handling
  s.add_dependency "will_paginate", "~> 3.1"      # pagination
  s.add_dependency 'country_select', "~> 1.3"
  # TODO s.add_dependency 'country_select', "~> 3.0"     # [todo] v2.x requires changes
  s.add_dependency 'paper_trail', '~> 7.0'      # table versioning
  s.add_dependency "liquid", "~> 2.6"
  # TODO s.add_dependency "liquid", "~> 4.0"
  s.add_dependency "sanitize", "~> 4.4"
  s.add_dependency 'acts_as_commentable', "~> 4.0.2" # we customize our usage, so can't use the 'with_threading' version
  s.add_dependency 'acts_as_votable', '~> 0.10.0'
  s.add_dependency 'acts_as_follower', '~> 0.2.1'
  s.add_dependency 'ancestry', "~> 2.2"
  s.add_dependency 'ranked-model', '~> 0.4.0'     # sort order for a list
  s.add_dependency 'amoeba', '~> 3.0'             # [todo] (see if still needed) for handling model duplicating
  s.add_dependency 'babosa', '~> 1.0'             # for better unicode slug handling with friendly_id
  s.add_dependency 'aasm', '~> 3.3.1'          # [todo] v4.x requires changes
  # TODO s.add_dependency 'aasm', '~> 4.12'          # [todo] v4.x requires changes
  s.add_dependency 'money-rails', '~> 1.8'
  s.add_dependency 'globalize', '~> 5.1.0.beta1'        # translations in database
  s.add_dependency 'exception_notification', '~> 4.2'
  s.add_dependency 'aws-sdk', '~> 1.49'
  # TODO s.add_dependency 'aws-sdk', '~> 2'
  s.add_dependency 'biggs', "~> 0.3.3"            # address formatting
  s.add_dependency 'codemirror-rails', '~> 5.16'
  s.add_dependency 'mini_magick', '~> 4.7'
  s.add_dependency 'carrierwave', '~> 1.0'
  s.add_dependency 'delayed_job_active_record', '~> 4.1'
  s.add_dependency 'delayed_job', '~> 4.1'
  s.add_dependency 'daemons', '~> 1.2'
  s.add_dependency 'recaptcha', '~> 4.1'
  s.add_dependency 'highline', '~> 1.7' # Necessary for the install generator
  s.add_dependency 'activemerchant', '~> 1.63.0'  #--| here (instead of dm_event) because
  s.add_dependency 'offsite_payments', '~> 2.2'   #--| of PaymentHistory model
  
  s.add_dependency 'acts-as-taggable-on', '~> 4.0'
  s.add_dependency 'kramdown', "~> 1.9"
  s.add_dependency "RedCloth", "~> 4.3"
  s.add_dependency "rolify", "~> 5.0"           # User Roles
  s.add_dependency 'friendly_id', "~> 5.2.0"
end
