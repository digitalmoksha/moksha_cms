$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dm_cms/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dm_cms"
  s.version     = DmCms::VERSION
  s.authors     = ["Brett Walker"]
  s.email       = ["brett@digitalmoksha.com"]
  s.homepage    = ""
  s.summary     = "Content Management Engine"
  s.description = "Content Management Engine"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
  # s.add_dependency "jquery-rails"

  s.add_dependency "RedCloth", "~> 4.2"
  s.add_dependency "bluecloth", "~> 2.2"
  s.add_dependency "liquid", "~> 2.3"
  s.add_dependency 'ancestry'
  s.add_dependency 'acts_as_list'

  #s.add_development_dependency "sqlite3"
end
