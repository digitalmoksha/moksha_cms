require_relative '../core/lib/dm_core/version'

#--- Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dm_lms"
  s.version     = DmCore::VERSION
  s.authors     = ["Brett Walker"]
  s.email       = ["github@digitalmoksha.com"]
  s.homepage    = "https://github.com/digitalmoksha/moksha_cms"
  s.licenses    = ['MIT']
  s.summary     = "Part of MokshaCms, Learning Management Engine"
  s.description = "Part of MokshaCms, Learning Management Engine"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  # dont' forget to add 'require' statement in engine.rb for any new dependencies
  s.add_dependency 'dm_admin', s.version
  s.add_dependency 'dm_core', s.version
end
