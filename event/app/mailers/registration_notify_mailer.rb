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
    @bcc                        = []
    @bcc                       << account.preferred_archive_email if account.preferred_archive_email
    @bcc                       << contact_email if registration.workshop.bcc_contact_email
    @registration               = registration
    @content                    = content
    @state                      = substitutions['state']

    headers({ "Reply-To" => contact_email != "" ? contact_email : account.preferred_smtp_from_email,
              "Return-Path" => account.preferred_smtp_from_email })

    theme(account.account_prefix)
    mail(to: @recipients, subject: @subject, bcc: @bcc) do |format|
      format.text { render "layouts/email_templates/dm_event_registration_notify.text.erb" }
      format.html { render "layouts/email_templates/dm_event_registration_notify.html.erb" }
    end
  end
end
