DmCore.configure do |config|
  config.default_locale = :en
  config.locales        = [:en, :de, :ja, :cs, :fi, :at, :fr]
  config.enable_themes  = true
end
Rails.application.config.i18n.available_locales = DmCore.config.locales