require 'rake'
require 'rubygems/package_task'

MOKSHA_GEMS = %w(admin core cms event forum newsletter).freeze

task default: :test

desc "Runs all tests in all MokshaCms engines"
task test: :test_app do
  MOKSHA_GEMS.each do |gem_name|
    Dir.chdir("#{File.dirname(__FILE__)}/#{gem_name}") do
      sh 'rspec'
    end
  end
end

desc "Generates a dummy app for testing for every MokshaCms engine"
task :test_app do
  MOKSHA_GEMS.each do |gem_name|
    Dir.chdir("#{File.dirname(__FILE__)}/#{gem_name}") do
      sh 'bundle install'
      sh 'rake test_app'
    end
  end
end

desc "clean the whole repository by removing all the generated files"
task :clean do
  rm_f  "Gemfile.lock"
  rm_rf "sandbox"
  rm_rf "pkg"

  MOKSHA_GEMS.each do |gem_name|
    rm_f  "#{gem_name}/Gemfile.lock"
    rm_rf "#{gem_name}/pkg"
    rm_rf "#{gem_name}/spec/dummy"
  end
end

namespace :gem do
  def version
    DmCore::VERSION
  end

  def for_each_gem
    MOKSHA_GEMS.each do |gem_name|
      yield "pkg/dm_#{gem_name}-#{version}.gem"
    end
    yield "pkg/moksha_cms-#{version}.gem"
  end

  desc "Current gem version"
  task :version do
    puts version
  end

  desc "Build all MokshaCms gems"
  task :build do
    pkgdir = File.expand_path("../pkg", __FILE__)
    FileUtils.mkdir_p pkgdir

    MOKSHA_GEMS.each do |gem_name|
      Dir.chdir(gem_name) do
        sh "gem build dm_#{gem_name}.gemspec"
        mv "dm_#{gem_name}-#{version}.gem", pkgdir
      end
    end

    sh "gem build moksha_cms.gemspec"
    mv "moksha_cms-#{version}.gem", pkgdir
  end

  desc "Install all MokshaCms gems"
  task install: :build do
    for_each_gem do |gem_path|
      Bundler.with_clean_env do
        sh "gem install #{gem_path}"
      end
    end
  end

  desc "Release all gems to rubygems"
  task release: :build do
    sh "git tag -a -m \"Version #{version}\" v#{version}"

    for_each_gem do |gem_path|
      sh "gem push '#{gem_path}'"
    end
  end
end

# desc "Creates a sandbox application for simulating the MokshaCms code in a deployed Rails app"
# task :sandbox do
#   Bundler.with_clean_env do
#     exec("lib/sandbox.sh")
#   end
# end
