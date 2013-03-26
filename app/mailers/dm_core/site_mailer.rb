# Uses an interceptor hook to set the smtp_settings to values from the account
# All mailers should inherit from this class
#------------------------------------------------------------------------------
class DmCore::SiteMailer < ActionMailer::Base

  class DynamicSettingsInterceptor
     def self.delivering_email(message)
       message.delivery_method.settings.merge!(Account.current.smtp_settings)
       message.from     = Account.current.preferred_smtp_from_email
       message.reply_to = Account.current.preferred_smtp_from_email
     end
   end
   register_interceptor DynamicSettingsInterceptor

end