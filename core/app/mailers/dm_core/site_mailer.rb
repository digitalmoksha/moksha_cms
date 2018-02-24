# Uses an interceptor hook to set the smtp_settings to values from the account
# All mailers should inherit from this class
#------------------------------------------------------------------------------
class DmCore::SiteMailer < ApplicationMailer
  layout 'email_templates/default_email_layout'

  class DynamicSettingsInterceptor
    def self.delivering_email(message)
      unless Account.current.nil?
        message.delivery_method.settings.merge!(Account.current.smtp_settings)
        message.from     = Account.current.preferred_smtp_from_email if message.from.blank?
        message.reply_to = Account.current.preferred_smtp_from_email if message.reply_to.blank?
      end
    end
  end

  register_interceptor DynamicSettingsInterceptor
end
