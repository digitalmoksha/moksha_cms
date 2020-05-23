if (Rails.env.production? || Rails.env.staging?) && Rails.application.secrets[:sentry_dsn].present?
  Raven.configure do |config|
    config.dsn = Rails.application.secrets[:sentry_dsn]
  end
end
