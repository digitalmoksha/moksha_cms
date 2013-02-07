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
  s.summary     = "Core functionality, including interationalization"
  s.description = "Core functionality, including interationalization"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  #--- dont' forget to add 'require' statement in engine.rb
  s.add_dependency "rails", "~> 3.2.11"
  s.add_dependency 'jquery-rails'
  s.add_dependency 'jquery-ui-rails'
  s.add_dependency "mysql2", ">= 0.3.11"
  s.add_dependency 'devise', '~> 2.1'         # Authenication
  s.add_dependency "rolify", ">= 3.2.0"       # User Roles
  
  s.add_dependency "simple_form", "~> 2.0"    # Form handling
  s.add_dependency "will_paginate", "~> 3.0"  # pagintation
  s.add_dependency "globalize3", ">= 0.3.0"   # translations in database
  s.add_dependency 'country_select'           
  s.add_dependency 'paper_trail', '~> 2'      # table versioning
  
  #--- make sure the following gems are included in your app's Gemfile
  # gem 'easy_globalize3_accessors', :git => 'git://github.com/digitalmoksha/easy_globalize3_accessors.git'
  # gem "preferences", "~> 0.5.0", :git => "git://github.com/madebydna/preferences.git"
  
end
