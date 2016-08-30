$:.push File.expand_path("../lib", __FILE__)

#--- Maintain your gem's version:
require "dm_newsletter/version"

#--- Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dm_newsletter"
  s.version     = DmNewsletter::VERSION
  s.authors     = ["Brett Walker"]
  s.email       = ["github@digitalmoksha.com"]
  s.homepage    = ""
  s.summary     = "Newsletter Engine"
  s.description = "Newsletter Engine"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'rails', '> 4.2', '< 5.1'

  #--- dont' forget to add 'require' statement in engine.rb
  s.add_dependency 'gibbon', '~> 1.2.0'

  #--- make sure the following gems are included in your app's Gemfile
  # gem 'dm_ruby_extensions', :git => 'git://github.com/digitalmoksha/dm_ruby_extensions.git'
  # gem 'dm_core', :git => 'git://github.com/digitalmoksha/dm_core.git'

end