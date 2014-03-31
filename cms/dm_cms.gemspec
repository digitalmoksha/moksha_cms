$:.push File.expand_path("../lib", __FILE__)

#--- Maintain your gem's version:
require "dm_cms/version"

#--- Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dm_cms"
  s.version     = DmCms::VERSION
  s.authors     = ["Brett Walker"]
  s.email       = ["github@digitalmoksha.com"]
  s.homepage    = ""
  s.summary     = "Content Management Engine"
  s.description = "Content Management Engine"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"

  #--- dont' forget to add 'require' statement in engine.rb
  s.add_dependency 'ancestry', "~> 2.0.0"
  s.add_dependency 'meta-tags-helpers', '~> 0.2.0'
  s.add_dependency 'mail_form', '~> 1.5.0'
  
  #--- make sure the following gems are included in your app's Gemfile
  # gem 'dm_ruby_extensions', :git => 'git://github.com/digitalmoksha/dm_ruby_extensions.git'
  # gem 'dm_core', :git => 'git://github.com/digitalmoksha/dm_core.git'

end
