# encoding: UTF-8
require_relative 'core/lib/dm_core/version.rb'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'moksha_cms'
  s.version     = DmCore::VERSION
  s.authors     = ["Brett Walker"]
  s.email       = ["github@digitalmoksha.com"]
  s.homepage    = 'https://github.com/digitalmoksha/moksha_cms'
  s.license     = 'MIT'
  s.summary     = 'MokshaCMS, A Full-stack Content Management framework for Ruby on Rails'
  s.description = 'MokshaCMS, A Full-stack Content Management framework for Ruby on Rails, providing content/blog management, event management,
  forums, and newsletter integration.'

  s.files        = Dir['README.md', 'lib/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'


  s.add_dependency 'dm_core', s.version
end