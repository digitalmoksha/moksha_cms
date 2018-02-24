# By placing all of MokshaCms's shared dependencies in this file and then loading
# it for each component's Gemfile, we can be sure that we're only testing just
# the one component of MokshaCms.
source 'https://rubygems.org'

gem 'rails', '5.0.6'

gem 'dm_preferences',         '~> 1.5'
gem 'themes_for_rails',       git: 'https://github.com/digitalmoksha/themes_for_rails.git'
gem 'aced_rails',             git: 'https://github.com/digitalmoksha/aced_rails.git'

gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'therubyracer', platforms: :ruby

group :development, :test do
  gem 'sqlite3'
  gem 'pry-byebug'
  gem 'thin' # use the Thin webserver during development

  gem 'mocha', '~> 1.2', :require => false
  gem 'rspec-rails', '~> 3.5'
  gem 'factory_bot_rails', '~> 4.8'

  gem 'rubocop', '~> 0.52.1'
  gem 'rubocop-rspec', '~> 1.22.1'

  gem 'gitlab-styles', require: false # use the GitLab rubocop styles
end

group :test do
  gem 'faker', '~> 1.7'
  gem 'capybara', '~> 2.13'
  gem 'database_cleaner', '~> 1.5'
  gem 'launchy', '~> 2.4'
  gem 'selenium-webdriver', '~> 3.3'
  gem 'rspec-formatter-webkit'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers', git: 'https://github.com/thoughtbot/shoulda-matchers.git', branch: 'rails-5'
  gem 'syntax'
end
