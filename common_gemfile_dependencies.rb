# By placing all of MokshaCms's shared dependencies in this file and then loading
# it for each component's Gemfile, we can be sure that we're only testing just
# the one component of MokshaCms.
source 'https://rubygems.org'

gem 'rails', '5.1.7'

gem 'dm_preferences',         '~> 1.5'
gem 'themes_for_rails',       git: 'https://github.com/digitalmoksha/themes_for_rails.git'
gem 'aced_rails',             git: 'https://github.com/digitalmoksha/aced_rails.git'

gem 'sass-rails', '~> 6.0'
gem 'uglifier', '>= 4.2.0'
gem 'coffee-rails', '~> 4.2'
gem 'therubyracer', platforms: :ruby

group :development, :test do
  gem 'sqlite3', '~> 1.4.2'
  gem 'pry-byebug'
  gem 'thin' # use the Thin webserver during development

  gem 'mocha', '~> 1.11', require: false
  gem 'rspec-rails', '~> 4.0'
  gem 'factory_bot_rails', '~> 5.2'

  gem 'rubocop', '~> 0.52'
  gem 'rubocop-rspec', '~> 1.22'
end

group :test do
  gem 'faker', '~> 2.11'
  gem 'capybara', '~> 3.32'
  gem 'database_cleaner', '~> 1.8'
  gem 'launchy', '~> 2.5'
  gem 'selenium-webdriver', '~> 3.142'
  gem 'rspec-formatter-webkit'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers'
  gem 'syntax'
  gem 'webmock', '~> 3.8'
end
