require 'spec_helper'
require 'rake'

RSpec.configure do |config|
  config.include RakeHelpers

  config.before(:all) do
    # Redirect stdout so specs don't have so much noise
    # $stdout = StringIO.new

    # Rake.application.rake_require 'tasks/helpers'
    Rake::Task.define_task :environment
  end

  # Reset stdout
  config.after(:all) do
    $stdout = STDOUT
  end
end
