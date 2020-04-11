# Useful links for testing Engines
# http://viget.com/extend/rails-engine-testing-with-rspec-capybara-and-factorygirl
# http://www.andrewhavens.com/posts/27/how-to-create-a-new-rails-engine-which-uses-rspec-and-factorygirl-for-testing/
# https://www.honeybadger.io/blog/2014/01/28/rails4-engine-controller-specs
#------------------------------------------------------------------------------

ENV["RAILS_ENV"] ||= 'test'

# Zeus does not preload RSpec
require 'rspec/core' unless defined? RSpec.configure

begin
  require File.expand_path("../dummy/config/environment", __FILE__)
rescue LoadError
  puts "Could not load dummy application. Please ensure you have run `bundle exec rake test_app`"
end

require 'rspec/rails'
require 'database_cleaner'
require 'validates_email_format_of/rspec_matcher'
require 'webmock/rspec'

# disallow external requests
WebMock.disable_net_connect!(allow_localhost: true)

ENGINE_RAILS_ROOT = File.join(File.dirname(__FILE__), '../')
Dir[File.join(ENGINE_RAILS_ROOT, "../core/spec/support/**/*.rb")].sort.each { |f| require f }
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].sort.each { |f| require f }

FactoryBot.definition_file_paths = [File.expand_path('../factories', __FILE__)]
FactoryBot.find_definitions

RSpec.configure do |config|
  config.color = true
  config.fail_fast = ENV['FAIL_FAST'] || false
  config.fixture_path = File.join(__dir__, "fixtures")
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec
  config.raise_errors_for_deprecations!

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.before do
    Rails.cache.clear
  end

  config.include FactoryBot::Syntax::Methods

  # Clean out the database state before the tests run
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
  end

  # Wrap all db isolated tests in a transaction
  config.around(db: :isolate) do |example|
    DatabaseCleaner.cleaning(&example)
  end

  # config.around do |example|
  #   Timeout.timeout(30, &example)
  # end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
