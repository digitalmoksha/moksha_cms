class PaymentReminderService

  REMINDER_SCHEDULE = [14, 30, 60]

  # Send out payment reminder emails to unpaid attendees
  #------------------------------------------------------------------------------
  def self.send_payment_reminder_emails(registration = nil)
    success = failed = 0
    Registration.unpaid.notwrittenoff.each do |registration|
      unless registration.check_if_writeoff!
        if registration.payment_owed.positive?
          if self.payment_reminder_due?(registration)
            self.send_reminder(registration) ? (success += 1) : (failed += 1)
          end
        end
      end
    end
    return {success: success, failed: failed}
  end

  # send a single reminder email, regardless of status
  #------------------------------------------------------------------------------
  def self.send_reminder(registration, queue = false)
    if queue
      email = PaymentReminderMailer.payment_reminder(registration).deliver_later
    else
      email = PaymentReminderMailer.payment_reminder(registration).deliver_now
    end
    if email
      registration.update_attribute(:payment_reminder_sent_on, Time.now)
      registration.update_attribute(:payment_reminder_history,  [Time.now] + registration.payment_reminder_history)
      return true
    else
      return false
    end
  end

  # Is it time to send a payment reminder?
  # policy:
  # 1. reminders are only sent when a payment is considered past due
  # 2. REMINDER_SCHEDULE indicates the days on which to send the next reminder email
  #    from the date when the payment was due
  # 3. It doesn't matter if payment was made recently - if the next payment is due,
  #    then we will follow the reminder schedule
  # 4. the entire payment schedule (re)starts based on when the last payment was due.
  # Note: The reminder schedule must be based off of when the last payment was due.
  # Suppose it was 12 monthly payments.  Just because they haven't paid in 6 months,
  # they should continue to be reminded until the last payment was due, and for the
  # entire reminder period after that.
  # Since theorectically the payment periods could be of any length, then we will
  # execute the reminder schedule as faithfully as possible until the next payment
  # is due.
  #------------------------------------------------------------------------------
  def self.payment_reminder_due?(registration)
    return false if !self.past_due?(registration) || registration.writtenoff_on
    now         = Time.now
    result      = false
    start_date  = registration.last_payment_due_on
    if start_date < now
      index = REMINDER_SCHEDULE.rindex {|x| start_date + x.days <= now}
      if index
        time_period   = start_date + REMINDER_SCHEDULE[index].days
        needs_sending = registration.payment_reminder_sent_on.nil? || registration.payment_reminder_sent_on < time_period

        # if they have made a payment during this period, then don't send a reminder
        needs_sending = false if !registration.last_payment_on.nil? && registration.last_payment_on > time_period
        result = needs_sending
      else
        # an initial payment reminder should be sent if the initial_payment_required_on date has passed
        if start_date == registration.workshop.initial_payment_required_on && registration.payment_reminder_sent_on.nil?
          result = true
        end
      end
    end
    return result
  end

  # past due means they haven't paid what they should have paid by now
  #------------------------------------------------------------------------------
  def self.past_due?(registration)
    return false if !registration.balance_owed.positive?
    if registration.workshop_price.recurring_payments?
      return registration.amount_paid < registration.recurring_what_should_be_paid_by_now
    else
      return Date.today > (registration.initial_payments_should_start_on)
    end
  end


end