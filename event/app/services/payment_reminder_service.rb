class PaymentReminderService

  # ## Dunning letters (payment reminders)
  #
  # The existing functionality should be extended that:
  #
  # - there are 4 types of dunning letters (1st day, 14 day, 30 day, 60 day)
  # - for each registration we track which type of dunning letter has already been send
  # - if all 4 types of dunning letters have been send and there was still no payment after an additional 30 days, the registration should be marked as written-off
  #

  REMINDER_SCHEDULE = [2, 14, 30, 60]
  WRITE_OFF_DAYS    = 90

  # Send out payment reminder emails to unpaid attendees, or to a specific one.
  # if a specific registration, then always send out the email
  #------------------------------------------------------------------------------
  def self.send_payment_reminder_emails(workshop, registration_id = 'all')
    success     = failed = 0
    unpaid_list = ( registration_id == 'all' ? workshop.registrations.unpaid : workshop.registrations.unpaid.where(id: registration_id) )
    unpaid_list.each do |registration|
      if (self.payment_reminder_due?(registration) && registration.payment_owed.positive?) || registration_id != 'all'
        email = PaymentReminderMailer.payment_reminder(registration).deliver_now
        if email
          registration.update_attribute(:payment_reminder_sent_on, Time.now)
          registration.update_attribute(:payment_reminder_history,  [Time.now] + registration.payment_reminder_history)
          success += 1
        else
          failed += 1
        end
      end
    end
    return {success: success, failed: failed}
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
    return false if !self.past_due?(registration)
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