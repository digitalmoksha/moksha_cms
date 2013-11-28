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
    @balance_owed               = registration.balance_owed.format
    @payment_link               = registration.payment_url

    headers = { "Reply-To" => account.preferred_smtp_from_email, "Return-Path" => account.preferred_smtp_from_email }

    mail(to: @recipients, subject: @subject, theme: account.account_prefix) do |format|
      format.text { render "layouts/email_templates/dm_event_payment_reminder.text.erb" }
      format.html { render "layouts/email_templates/dm_event_payment_reminder.html.erb" }
    end
  end

end