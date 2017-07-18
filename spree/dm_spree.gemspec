require_relative '../core/lib/dm_core/version.rb'

#--- Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dm_spree"
  s.version     = DmCore::VERSION
  s.authors     = ["Brett Walker"]
  s.email       = ["github@digitalmoksha.com"]
  s.homepage    = "https://github.com/digitalmoksha/moksha_cms"
  s.licenses    = ['MIT']
  s.summary     = "Part of MokshaCms, Spree Engine"
  s.description = "Part of MokshaCms, Spree Management Engine"

  s.files       = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files  = Dir["spec/**/*"]

  s.add_dependency 'dm_core', s.version

  # s.add_dependency 'spree', '~> 3.2.0'
  s.add_dependency 'spree_core', '~> 3.2.0'
  s.add_dependency 'spree_backend', '~> 3.2.0'
  # s.add_dependency 'spree_auth_devise', '~> 3.2'
  # s.add_dependency 'spree_gateway', '~> 3.2'
  #--- don't forget to add 'require' statement in engine.rb
end
