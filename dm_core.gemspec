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
  s.test_files = Dir["test/**/*"]

  #--- dont' forget to add 'require' statement in engine.rb
  s.add_dependency "rails", "~> 4.0.0"
  s.add_dependency 'actionview-encoded_mail_to'
  s.add_dependency 'devise', '~> 3.2.4'           # Authentication
  s.add_dependency "rolify", "~> 3.4.0"           # User Roles
  s.add_dependency "cancancan", "~> 1.8"          # Authorization
  # s.add_dependency "simple_form", "~> 3.0.1"    # Form handling
  s.add_dependency "simple_form", '~> 3.1.0.rc1'  # Form handling
  s.add_dependency "will_paginate", "~> 3.0.5"    # pagination
  s.add_dependency 'country_select', "~> 1.3.1"           
  s.add_dependency 'paper_trail', '~> 3.0.1'      # table versioning
  s.add_dependency "RedCloth", "~> 4.2.9"
  s.add_dependency 'kramdown', "~> 1.3.3"
  s.add_dependency "liquid", "~> 2.6.1"
  s.add_dependency "sanitize", "~> 2.1.0"
  s.add_dependency 'acts_as_commentable', "~> 4.0.1"
  s.add_dependency 'acts_as_votable', '~> 0.8.0'
  s.add_dependency 'acts_as_follower', '~> 0.2.1'
  s.add_dependency 'ancestry', "~> 2.0.0"
  s.add_dependency 'ranked-model', '~> 0.4.0'     # sort order for a list
  s.add_dependency 'acts-as-taggable-on', '~> 3.1'
  s.add_dependency 'amoeba', '~> 2.0'             # [todo] (see if still needed) for handling model duplicating
  s.add_dependency 'babosa', '~> 0.3'             # for better unicode slug handling with friendly_id
  s.add_dependency 'friendly_id', "~> 5.0.3"
  s.add_dependency 'aasm', '~> 3.1.1'
  s.add_dependency 'money-rails', '~> 0.9.0'
  s.add_dependency 'globalize', '4.0.1'        # translations in database. 4.0.2 introduced bug with touch: true and destroying CmsPost
  s.add_dependency 'exception_notification', '4.0.1'
  s.add_dependency 'aws-sdk', '~> 1.0'
  s.add_dependency 'biggs', "~> 0.3.3"            # address formatting
  s.add_dependency 'codemirror-rails'
  
  #--- make sure the following gems are included in your app's Gemfile
  # gem "preferences", "~> 0.5.0", :git => "git://github.com/madebydna/preferences.git"

  s.add_development_dependency 'rspec-rails', '~> 2.14'
end
