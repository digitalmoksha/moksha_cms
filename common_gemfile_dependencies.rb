# By placing all of MokshaCms's shared dependencies in this file and then loading
# it for each component's Gemfile, we can be sure that we're only testing just
# the one component of MokshaCms.
source 'https://rubygems.org'

gem 'rails', '~> 6.0.2', '>= 6.0.2.1'

gem 'dm_preferences',         '~> 1.5'
gem 'themes_for_rails',       git: 'https://github.com/digitalmoksha/themes_for_rails.git'
gem 'aced_rails',             git: 'https://github.com/digitalmoksha/aced_rails.git'

gem 'puma', '~> 4.1'
gem 'sass-rails', '>= 6'
gem 'uglifier', '>= 4.2.0'
gem 'coffee-rails', '~> 5.0'
gem 'mini_racer', platforms: :ruby
gem 'bootsnap', '>= 1.4.2', require: false
gem 'webpacker', '~> 4.0'

group :development, :test do
  gem 'sqlite3', '~> 1.4'
  gem 'pry-byebug'
  gem 'thin' # use the Thin webserver during development

  gem 'mocha', '~> 1.11', require: false
  gem 'rspec-rails', '~> 4.0'
  gem 'factory_bot_rails', '~> 6.1'

  gem 'rubocop', '~> 0.88'
  gem 'rubocop-rspec', '~> 1.42'
end

group :development do
  gem 'web-console', '>= 4.0'
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'faker', '~> 2.11'
  gem 'capybara', '>= 2.15'
  gem 'database_cleaner', '~> 1.8'
  gem 'launchy', '~> 2.5'
  gem 'selenium-webdriver'
  gem 'rspec-formatter-webkit'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers'
  gem 'syntax'
  gem 'webdrivers'
  gem 'webmock', '~> 3.8'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
