module DmCore
  module RecaptchaHelper
    #------------------------------------------------------------------------------
    def add_recaptcha
      return '' unless Rails.application.secrets[:recaptcha_site_key]

      recaptcha_tags(site_key: Rails.application.secrets[:recaptcha_site_key], hl: I18n.locale)
    end

    #------------------------------------------------------------------------------
    def captcha_solved?
      return true unless Rails.application.secrets[:recaptcha_secret_key]
      return true if verify_recaptcha(secret_key: Rails.application.secrets[:recaptcha_secret_key])

      flash[:error] = 'There was an error with the reCAPTCHA. Please solve the reCAPTCHA again.'
      flash.delete :recaptcha_error
      false
    end
  end
end
