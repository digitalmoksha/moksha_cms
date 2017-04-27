class PaymentReminderMailer < DmCore::SiteMailer
  
  helper  DmCore::LiquidHelper
  helper  DmCore::UrlHelper
  helper  DmCore::AccountHelper

  layout 'email_templates/dm_event_email_layout'
  
  #------------------------------------------------------------------------------
  def payment_reminder(registration)
    account                     = registration.account
    @subject                    = I18n.t('ems.ticket_payment_reminder_subject', value: registration.workshop.title)
    @recipients                 = registration.email
    @registration               = registration
    @payment_owed               = registration.payment_owed.format
    @payment_link               = registration.payment_url

    theme(account.account_prefix)
    headers = { "Reply-To" => account.preferred_smtp_from_email, "Return-Path" => account.preferred_smtp_from_email }
    mail(to: @recipients, subject: @subject,
         bcc: account.preferred_archive_email,
         template_path: 'layouts/email_templates',
         template_name: 'dm_event_payment_reminder')
  end

end