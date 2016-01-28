$:.push File.expand_path("../lib", __FILE__)

#--- gem's version:
require "dm_forum/version"

#--- Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dm_forum"
  s.version     = DmForum::VERSION
  s.authors     = ["Brett Walker"]
  s.email       = ["github@digitalmoksha.com"]
  s.homepage    = ""
  s.summary     = "Forum Engine"
  s.description = "Forum Engine"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'rails', '>= 4.2', '< 5.1'

  #--- dont' forget to add 'require' statement in engine.rb

  #--- make sure the following gems are included in your app's Gemfile
  # gem 'dm_ruby_extensions', :git => 'git://github.com/digitalmoksha/dm_ruby_extensions.git'
  # gem 'dm_core', :git => 'git://github.com/digitalmoksha/dm_core.git'
  # gem 'dm_cms', :git => 'git://github.com/digitalmoksha/dm_cms.git'
end
