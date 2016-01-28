source "http://rubygems.org"

gem 'rails', '4.2.5.1'

# Declare your gem's dependencies in dm_core.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# jquery-rails is used by the dummy application
gem "jquery-rails"
gem 'jquery-ui-rails'

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

gem 'dm_preferences',         '~> 1.0'
gem 'themes_for_rails',     git: 'git://github.com/digitalmoksha/themes_for_rails.git'
gem 'aced_rails',           git: 'git://github.com/digitalmoksha/aced_rails.git'

group :development, :test do
  gem 'sqlite3'
  gem 'byebug'
  gem 'ruby-growl', '~> 4.1'
  gem 'thin'  # use the Thin webserver during development

  gem 'mocha', '~> 1.1.0', :require => false
  gem 'rspec-rails', '~> 3.1.0'
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