require_relative '../core/lib/dm_core/version.rb'

Gem::Specification.new do |s|
  s.name        = "dm_newsletter"
  s.version     = DmCore::VERSION
  s.authors     = ["Brett Walker"]
  s.email       = ["github@digitalmoksha.com"]
  s.homepage    = "https://github.com/digitalmoksha/moksha_cms"
  s.licenses    = ['MIT']
  s.summary     = "Part of MokshaCms, Newsletter Engine"
  s.description = "Part of MokshaCms, Newsletter Management Engine"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'dm_core', s.version

  # dont' forget to add 'require' statement in engine.rb
  s.add_dependency 'gibbon', '~> 3.3'
end
