require 'rails/generators'
require 'highline/import'
require 'bundler'
require 'bundler/cli'

module MokshaCms
  class InstallGenerator < Rails::Generators::Base
    class_option :migrate, type: :boolean, default: true, banner: 'Run MokshaCms migrations'
    class_option :seed, type: :boolean, default: true, banner: 'load seed data (migrations must be run)'
    class_option :sample, type: :boolean, default: true, banner: 'load sample data (migrations must be run)'
    class_option :auto_accept, type: :boolean
    class_option :user_class, type: :string
    class_option :admin_email, type: :string
    class_option :admin_password, type: :string
    class_option :lib_name, type: :string, default: 'dm_core'
    class_option :enforce_available_locales, type: :boolean, default: nil

    def self.source_paths
      paths = self.superclass.source_paths
      paths << File.expand_path('../templates', "../../#{__FILE__}")
      paths << File.expand_path('../templates', "../#{__FILE__}")
      paths << File.expand_path('../templates', __FILE__)
      paths.flatten
    end

    def prepare_options
      @run_migrations = options[:migrate]
      @load_seed_data = options[:seed]
      @load_sample_data = options[:sample]

      unless @run_migrations
         @load_seed_data = false
         @load_sample_data = false
      end
    end

    def add_files
      template 'config/initializers/dm_core.rb', 'config/initializers/dm_core.rb'
    end

    def additional_tweaks
      return unless File.exists? 'public/robots.txt'
      append_file "public/robots.txt", <<-ROBOTS
User-agent: *
Disallow: /checkout
Disallow: /cart
Disallow: /orders
Disallow: /user
Disallow: /account
Disallow: /api
Disallow: /password
      ROBOTS
    end

    def setup_assets
      # @lib_name = 'moksha_cms'
      # %w{javascripts stylesheets images}.each do |path|
      #   empty_directory "vendor/assets/#{path}/moksha_cms/frontend" if defined? DmCms || Rails.env.test?
      #   empty_directory "vendor/assets/#{path}/moksha_cms/backend" if defined? DmCore || Rails.env.test?
      # end
      #
      # if defined? DmCms || Rails.env.test?
      #   template "vendor/assets/javascripts/moksha_cms/frontend/all.js"
      #   template "vendor/assets/stylesheets/moksha_cms/frontend/all.css"
      # end
      #
      # if defined? DmCore || Rails.env.test?
      #   template "vendor/assets/javascripts/moksha_cms/backend/all.js"
      #   template "vendor/assets/stylesheets/moksha_cms/backend/all.css"
      # end
    end

    # def create_overrides_directory
    #   empty_directory "app/overrides"
    # end

    # def configure_application
    #   application <<-APP
    #
    # config.to_prepare do
    #   # Load application's model / class decorators
    #   Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
    #     Rails.configuration.cache_classes ? require(c) : load(c)
    #   end
    #
    #   # Load application's view overrides
    #   Dir.glob(File.join(File.dirname(__FILE__), "../app/overrides/*.rb")) do |c|
    #     Rails.configuration.cache_classes ? require(c) : load(c)
    #   end
    # end
    #   APP
    #
    #   if !options[:enforce_available_locales].nil?
    #     application <<-APP
    # # Prevent this deprecation message: https://github.com/svenfuchs/i18n/commit/3b6e56e
    # I18n.enforce_available_locales = #{options[:enforce_available_locales]}
    #     APP
    #   end
    # end

#     def include_seed_data
#       append_file "db/seeds.rb", <<-SEEDS
# \n
# DmCore::Engine.load_seed if defined?(DmCore)
# DmCms::Engine.load_seed if defined?(DmCms)
#       SEEDS
#     end

    def install_migrations
      say_status :copying, "migrations"
      silence_stream(STDOUT) do
        silence_warnings { rake 'railties:install:migrations' }
      end
    end

    def create_database
      say_status :creating, "database"
      silence_stream(STDOUT) do
        silence_stream(STDERR) do
          silence_warnings { rake 'db:create' }
        end
      end
    end

    def run_migrations
      if @run_migrations
        say_status :running, "migrations"
        silence_stream(STDOUT) do
          silence_stream(STDERR) do
            silence_warnings { rake 'db:migrate' }
          end
        end
      else
        say_status :skipping, "migrations (don't forget to run rake db:migrate)"
      end
    end

    # def populate_seed_data
    #   if @load_seed_data
    #     say_status :loading,  "seed data"
    #     rake_options=[]
    #     rake_options << "AUTO_ACCEPT=1" if options[:auto_accept]
    #     rake_options << "ADMIN_EMAIL=#{options[:admin_email]}" if options[:admin_email]
    #     rake_options << "ADMIN_PASSWORD=#{options[:admin_password]}" if options[:admin_password]
    #
    #     cmd = lambda { rake("db:seed #{rake_options.join(' ')}") }
    #     if options[:auto_accept] || (options[:admin_email] && options[:admin_password])
    #       silence_stream(STDOUT) do
    #         silence_stream(STDERR) do
    #           silence_warnings &cmd
    #         end
    #       end
    #     else
    #       cmd.call
    #     end
    #   else
    #     say_status :skipping, "seed data (you can always run rake db:seed)"
    #   end
    # end

    # def load_sample_data
    #   if @load_sample_data
    #     say_status :loading, "sample data"
    #     silence_stream(STDOUT) do
    #       silence_stream(STDERR) do
    #         silence_warnings { rake 'spree_sample:load' }
    #       end
    #     end
    #   else
    #     say_status :skipping, "sample data (you can always run rake spree_sample:load)"
    #   end
    # end

    def notify_about_routes
      if options[:lib_name] == 'dm_cms'
        insert_into_file File.join('config', 'routes.rb'), after: "Rails.application.routes.draw do\n" do
          dm_cms_routes
        end
      end

      insert_into_file File.join('config', 'routes.rb'), after: "Rails.application.routes.draw do\n" do
        dm_core_routes
      end

      unless options[:quiet]
        puts "*" * 50
        puts "We added the following line to your application's config/routes.rb file:"
        puts " "
        puts "    mount Spree::Core::Engine, at: '/'"
      end
    end

    def complete
      unless options[:quiet]
        puts "*" * 50
        puts "Spree has been installed successfully. You're all ready to go!"
        puts " "
        puts "Enjoy!"
      end
    end

    protected

    def javascript_exists?(script)
      extensions = %w(.js.coffee .js.erb .js.coffee.erb .js)
      file_exists?(extensions, script)
    end

    def stylesheet_exists?(stylesheet)
      extensions = %w(.css.scss .css.erb .css.scss.erb .css)
      file_exists?(extensions, stylesheet)
    end

    def file_exists?(extensions, filename)
      extensions.detect do |extension|
        File.exists?("#{filename}#{extension}")
      end
    end

    def dm_core_routes
      <<-ROUTES
  scope ":locale" do
    devise_for :users, controllers: { registrations: "registrations", confirmations: 'confirmations' }
  end
  themes_for_rails
  mount DmCore::Engine, :at => '/'
ROUTES
    end

    def dm_cms_routes
      <<-ROUTES
  mount DmCms::Engine => '/'
  scope ":locale" do
    get   '/index',                 controller: 'dm_cms/pages', action: :show, slug: 'index', as: :index
  end

  #--- use match instead of root to fix issue where sometimes '?locale=de' is appeneded
  get   '/(:locale)',            :controller => 'dm_cms/pages', :action => :show, :slug => 'index', :as => :root
ROUTES
    end

    private

    def silence_stream(stream)
      old_stream = stream.dup
      stream.reopen(RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ ? 'NUL:' : '/dev/null')
      stream.sync = true
      yield
    ensure
      stream.reopen(old_stream)
      old_stream.close
    end
  end
end
