class RegistrationNotifyMailer < DmCore::SiteMailer
  
  #--- [todo] See how we can use a defined system layout, but different one per site
  # layout "system_email_layout"
  
  helper  DmCore::LiquidHelper
  helper  DmCore::UrlHelper
  helper  DmCore::AccountHelper
    
  layout 'email_templates/dm_event_email_layout'

  #------------------------------------------------------------------------------
  def registration_notify(registration, content, substitutions)
    contact_email               = registration.workshop.contact_email
    account                     = registration.account
    @subject                    = substitutions['subject']
    @recipients                 = registration.email
    @bcc                        = account.preferred_webmaster_email
    @registration               = registration
    @content                    = content
    @state                      = substitutions['state']

    headers = { "Reply-To" => (contact_email != "") ? contact_email : account.preferred_smtp_from_email, 
                "Return-Path" => account.preferred_smtp_from_email }

    mail(:to => @recipients, :subject => @subject, :theme => account.account_prefix) do |format|
      format.text { render "layouts/email_templates/dm_event_registration_notify.text.erb" }
      format.html { render "layouts/email_templates/dm_event_registration_notify.html.erb" }
    end
  end

  # # send a comment notification email
  # #------------------------------------------------------------------------------
  # def comment_notify(event_registration, content, substitutions)
  #   contact_email               = event_registration.event_workshop.contact_email
  #   account                     = event_registration.event_workshop.event.account
  #   @subject                    = account.preferred(:event_prepend_subject) + substitutions['subject']
  #   @recipients                 = event_registration.email_address
  #   @from                       = account.preferred(:event_email_from)
  #   @bcc                        = account.preferred(:event_admin_email)
  #   @event_registration         = event_registration
  #   @content                    = content
  #   @state                      = substitutions['state']
  #   @link                       = account.preferred(:system_main_site) + "/#{I18n.locale}" + Hanuman::Application.config.comment_registration
  # 
  #   headers = { "Reply-To" => "no-reply@hanumanwebpublishing.com", 
  #               "Return-Path" => account.preferred(:event_return_path) }
  # 
  #   mail(:to => @recipients, :subject => @subject, :from => @from) do |format|
  #     format.text { render "#{account.path_prefix}_comment_notify.text.erb" }
  #     format.html { render "#{account.path_prefix}_comment_notify.html.erb" }
  #   end
  # end
end