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
  s.add_dependency "rails", "~> 3.2.13"
  s.add_dependency 'jquery-rails'
  s.add_dependency 'jquery-ui-rails'
  s.add_dependency "mysql2", ">= 0.3.11"
  s.add_dependency 'devise', '~> 2.1'         # Authentication
  s.add_dependency "rolify", ">= 3.2.0"       # User Roles
  s.add_dependency "cancan", "~> 1.6"         # Authorization
  s.add_dependency "simple_form", "~> 2.0"    # Form handling
  s.add_dependency "will_paginate", "~> 3.0"  # pagination
  s.add_dependency 'country_select'           
  s.add_dependency 'paper_trail', '~> 2'      # table versioning
  s.add_dependency "RedCloth", "~> 4.2"
  s.add_dependency "bluecloth", "~> 2.2"
  s.add_dependency 'kramdown'
  s.add_dependency "liquid", "~> 2.3"
  s.add_dependency 'acts_as_commentable', "~> 4.0"
  s.add_dependency 'ancestry'
  s.add_dependency 'ranked-model'             # sort order for a list
  s.add_dependency 'amoeba', '~> 2.0'         # for handling model duplicating
  s.add_dependency 'friendly_id', "~> 4.0.9"
  s.add_dependency 'aasm'
  s.add_dependency 'money-rails'
  
  #--- really, we need a patched level of globalize for best performance.  include main one here, and override in app's gem file
  # gem 'globalize3', :git => 'git://github.com/svenfuchs/globalize3.git', :ref => 'dfad4bfeb331d39222c49e321515927b378bfd28'
  s.add_dependency "globalize3", ">= 0.3.0"   # translations in database
  
  #--- make sure the following gems are included in your app's Gemfile
  # gem 'easy_globalize3_accessors', :git => 'git://github.com/digitalmoksha/easy_globalize3_accessors.git'
  # gem "preferences", "~> 0.5.0", :git => "git://github.com/madebydna/preferences.git"

  s.add_development_dependency 'rspec-rails', '~> 2.0'
end
