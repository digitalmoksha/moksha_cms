$:.push File.expand_path("../lib", __FILE__)

#--- gem's version:
require "dm_event/version"

#--- Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dm_event"
  s.version     = DmEvent::VERSION
  s.authors     = ["Brett Walker"]
  s.email       = ["github@digitalmoksha.com"]
  s.homepage    = ""
  s.summary     = "Event Engine"
  s.description = "Event Engine"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.0.0"

  #--- dont' forget to add 'require' statement in engine.rb
  s.add_dependency 'ranked-model', '~> 0.4.0'             # sort order for a list
  s.add_dependency 'money-rails', '~> 0.9.0'
  s.add_dependency 'activemerchant', '1.43.1'
  s.add_dependency 'mini_magick', '~> 3.7.0'
  s.add_dependency 'carrierwave', '~> 0.10.0'

  #--- make sure the following gems are included in your app's Gemfile
  # gem 'dm_ruby_extensions', :git => 'git://github.com/digitalmoksha/dm_ruby_extensions.git'
  # gem 'dm_core', :git => 'git://github.com/digitalmoksha/dm_core.git'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'

end
