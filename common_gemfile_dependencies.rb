# By placing all of MokshaCms's shared dependencies in this file and then loading
# it for each component's Gemfile, we can be sure that we're only testing just
# the one component of MokshaCms.
source 'https://rubygems.org'

gem 'dm_preferences',         '~> 1.0'
gem 'themes_for_rails',     git: 'git://github.com/digitalmoksha/themes_for_rails.git'
gem 'aced_rails',           git: 'git://github.com/digitalmoksha/aced_rails.git'

group :development, :test do
  gem 'sqlite3'
  gem 'byebug'
  gem 'thin'  # use the Thin webserver during development

  gem 'mocha', '~> 1.1.0', :require => false
  gem 'rspec-rails', '~> 3.5.0'
  gem 'factory_girl_rails', '~> 4.4.1'
end

group :test do
  gem 'faker', '~> 1.4.3'
  gem 'capybara', '~> 2.4.3'
  gem 'database_cleaner', '~> 1.3.0'
  gem 'launchy', '~> 2.4.2'
  gem 'selenium-webdriver', '~> 2.43.0'
  gem 'rspec-formatter-webkit'
  gem 'syntax'
end