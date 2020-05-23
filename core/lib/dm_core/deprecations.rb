# send deprecation messages to Sentry
if (Rails.env.production? || Rails.env.staging?) && Rails.application.secrets[:sentry_dsn].present?
  ActiveSupport::Deprecation.behavior = [:log, :notify]
  ActiveSupport::Notifications.subscribe('deprecation.rails') do |_name, _start, _finish, _id, payload|
    Raven.capture_message(payload[:message])
  end
end
