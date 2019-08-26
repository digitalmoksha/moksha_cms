module DmCore
  module RecaptchaHelper
    def add_recaptcha
      return '' unless Rails.application.secrets[:recaptcha_site_key]

      recaptcha_tags(site_key: Rails.application.secrets[:recaptcha_site_key], hl: I18n.locale)
    end
  end
end
