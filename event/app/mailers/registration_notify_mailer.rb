class RegistrationNotifyMailer < DmCore::SiteMailer
  
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

end