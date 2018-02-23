require_relative '../core/lib/dm_core/version.rb'

#--- Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dm_admin"
  s.version     = DmCore::VERSION
  s.authors     = ["Brett Walker"]
  s.email       = ["github@digitalmoksha.com"]
  s.homepage    = "https://github.com/digitalmoksha/moksha_cms"
  s.licenses    = ['MIT']
  s.summary     = "Part of MokshaCms, Admin Engine"
  s.description = "Part of MokshaCms, Admin Engine"

  s.files       = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files  = Dir["spec/**/*"]

  s.add_dependency 'dm_core', s.version

  #--- dont' forget to add 'require' statement in engine.rb
  s.add_dependency               "font-awesome-rails"
  s.add_development_dependency   "will_paginate", "~> 3.1" # pagination
end
