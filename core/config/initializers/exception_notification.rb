# configure ExceptionNotification gem
#
# You need to configure the :sender_address and :exception_recipients in an
# initializer in your main app.  Create a `congif/initializers/expection_notification.rb`:

# if Rails.env.production? || Rails.env.staging?
#   notifier = ExceptionNotifier.registered_exception_notifier(:email)
#   notifier.base_options[:sender_address] = %{"#{Rails.application.config.app_name}" <exception.notifier@#{Rails.application.config.base_domain}>}
#   notifier.base_options[:exception_recipients] = [ Rails.application.config.exception_emails_to ]
# end
#------------------------------------------------------------------------------

if Rails.env.production? || Rails.env.staging?
  require 'exception_notification/rails'
  # for Sidekiq
  # require 'exception_notification/sidekiq'

  # for Resque
  # require 'resque/failure/multiple'
  # require 'resque/failure/redis'
  # require 'exception_notification/resque'
  #
  # Resque::Failure::Multiple.classes = [Resque::Failure::Redis, ExceptionNotification::Resque]
  # Resque::Failure.backend = Resque::Failure::Multiple

  ExceptionNotification.configure do |config|
    # Ignore additional exception types.
    # ActiveRecord::RecordNotFound, Mongoid::Errors::DocumentNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
    # config.ignored_exceptions += %w{ActionView::TemplateError CustomError}

    # Adds a condition to decide when an exception must be ignored or not.
    # The ignore_if method can be invoked multiple times to add extra conditions.
    # config.ignore_if do |exception, options|
    #   not Rails.env.production?
    # end

    # Notifiers =================================================================

    # Email notifier sends notifications by email.
    config.add_notifier :email, {
      email_prefix: "[Error] ",
      sections: %w{general_info request session backtrace environment},
      normalize_subject: true,
      email_format: :html
    }

    # Campfire notifier sends notifications to your Campfire room. Requires 'tinder' gem.
    # config.add_notifier :campfire, {
    #   :subdomain => 'my_subdomain',
    #   :token => 'my_token',
    #   :room_name => 'my_room'
    # }

    # HipChat notifier sends notifications to your HipChat room. Requires 'hipchat' gem.
    # config.add_notifier :hipchat, {
    #   :api_token => 'my_token',
    #   :room_name => 'my_room'
    # }

    # Webhook notifier sends notifications over HTTP protocol. Requires 'httparty' gem.
    # config.add_notifier :webhook, {
    #   :url => 'http://example.com:5555/hubot/path',
    #   :http_method => :post
    # }
  end
end
