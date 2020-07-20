require_relative '../core/lib/dm_core/version'

#--- Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dm_event"
  s.version     = DmCore::VERSION
  s.authors     = ["Brett Walker"]
  s.email       = ["github@digitalmoksha.com"]
  s.homepage    = "https://github.com/digitalmoksha/moksha_cms"
  s.licenses    = ['MIT']
  s.summary     = "Part of MokshaCms, Event Engine"
  s.description = "Part of MokshaCms, Event Management Engine"

  s.files       = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files  = Dir["spec/**/*"]

  s.add_dependency 'dm_cms', s.version
  s.add_dependency 'dm_core', s.version

  #--- don't forget to add 'require' statement in engine.rb
end
