$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dm_core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dm_core"
  s.version     = DmCore::VERSION
  s.authors     = ["Brett Walker"]
  s.email       = ["brett@digitalmoksha.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of DmCore."
  s.description = "TODO: Description of DmCore."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_dependency "mysql2", ">= 0.3.11"
  s.add_dependency "globalize3"
  s.add_dependency "easy_globalize3_accessors"
  
  #s.add_development_dependency "sqlite3"
end
