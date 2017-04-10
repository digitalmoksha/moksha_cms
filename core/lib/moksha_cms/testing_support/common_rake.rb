require 'generators/moksha_cms/dummy/dummy_generator'
require 'generators/moksha_cms/install/install_generator'

desc "Generates a dummy app for testing"
namespace :common do
  task :test_app, :user_class do |_t, args|
    args.with_defaults(user_class: "User")

    ENV['RAILS_ENV'] = 'test'

    MokshaCms::DummyGenerator.start ["--lib_name=#{ENV['LIB_NAME']}", "--quiet"]
    MokshaCms::InstallGenerator.start ["--lib_name=#{ENV['LIB_NAME']}", "--auto-accept", "--migrate=false", "--seed=false", "--sample=false", "--quiet", "--user_class=#{args[:user_class]}"]

    puts "Setting up dummy database..."
    system("bundle exec rake db:drop db:create db:migrate > #{File::NULL}")

    begin
      require "generators/#{ENV['LIB_NAME']}/install/install_generator"
      puts 'Running extension installation generator...'
      "#{ENV['LIB_NAME'].camelize}::Generators::InstallGenerator".constantize.start(["--auto-run-migrations"])
    rescue LoadError
      puts 'Skipping installation no generator to run...'
    end

    puts "Precompiling assets..."
    system("bundle exec rake assets:precompile > #{File::NULL}")
  end

  task :seed do |_t|
    puts "Seeding ..."
    system("bundle exec rake db:seed RAILS_ENV=test > #{File::NULL}")
  end
end
