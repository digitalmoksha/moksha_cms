$:.push File.expand_path("../lib", __FILE__)

#--- Maintain your gem's version:
require "dm_core/version"

#--- Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dm_core"
  s.version     = DmCore::VERSION
  s.authors     = ["Brett Walker"]
  s.email       = ["github@digitalmoksha.com"]
  s.homepage    = ""
  s.summary     = "Core functionality, including internationalization"
  s.description = "Core functionality, including internationalization"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  #--- dont' forget to add 'require' statement in engine.rb
  s.add_dependency 'rails', '>= 4.2', '< 5.1'
  s.add_dependency 'dm_ruby_extensions', '~> 1.0'
  s.add_dependency 'actionview-encoded_mail_to'
  s.add_dependency 'devise', '~> 3.5'           # Authentication
  s.add_dependency "rolify", "~> 5.0"           # User Roles
  s.add_dependency "cancancan", "~> 1.13"         # Authorization
  s.add_dependency "simple_form", '~> 3.2'        # Form handling
  s.add_dependency "will_paginate", "~> 3.1"      # pagination
  s.add_dependency 'country_select', "~> 1.3.1"   # [todo] v2.x requires changes
  s.add_dependency 'paper_trail', '~> 4.0.2'      # table versioning
  s.add_dependency "RedCloth", "~> 4.2.9"
  s.add_dependency 'kramdown', "~> 1.9"
  s.add_dependency "liquid", "~> 2.6"
  s.add_dependency "sanitize", "~> 4.0"
  s.add_dependency 'acts_as_commentable', "~> 4.0.2"
  s.add_dependency 'acts_as_votable', '~> 0.10.0'
  s.add_dependency 'acts_as_follower', '~> 0.2.1'
  s.add_dependency 'ancestry', "~> 2.1.0"
  s.add_dependency 'ranked-model', '~> 0.4.0'     # sort order for a list
  s.add_dependency 'acts-as-taggable-on', '~> 3.5'
  s.add_dependency 'amoeba', '~> 3.0'             # [todo] (see if still needed) for handling model duplicating
  s.add_dependency 'babosa', '~> 1.0'             # for better unicode slug handling with friendly_id
  s.add_dependency 'friendly_id', "~> 5.1.0"
  s.add_dependency 'aasm', '~> 3.3.1'          # [todo] v4.x requires changes
  s.add_dependency 'money-rails', '~> 1.6'
  s.add_dependency 'globalize', '~> 5.0.1'        # translations in database
  s.add_dependency 'exception_notification', '~> 4.1'
  s.add_dependency 'aws-sdk', '~> 1.49'
  s.add_dependency 'biggs', "~> 0.3.3"            # address formatting
  s.add_dependency 'codemirror-rails', '~> 5.6'
  s.add_dependency 'mini_magick', '~> 4.3.6'
  s.add_dependency 'carrierwave', '~> 0.10.0'
  
  #--- make sure the following gems are included in your app's Gemfile
  # gem "preferences", "~> 0.5.0", :git => "git://github.com/madebydna/preferences.git"
end
