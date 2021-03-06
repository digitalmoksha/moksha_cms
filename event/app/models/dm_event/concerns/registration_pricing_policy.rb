# Extends the Registration model with a state machine
#------------------------------------------------------------------------------
module DmEvent
  module Concerns
    module RegistrationPricingPolicy
      extend ActiveSupport::Concern

      WRITE_OFF_DAYS = 90

      # 'included do' causes the included code to be evaluated in the
      # conext where it is included (post.rb), rather than be
      # executed in the module's context (blorgh/concerns/models/post).
      #------------------------------------------------------------------------------
      included do
        # Price of this registration (without discount)
        #------------------------------------------------------------------------------
        def price
          workshop_price&.price ? workshop_price.price : Money.new(0, workshop.base_currency)
        end

        # Price with discount
        #------------------------------------------------------------------------------
        def discounted_price
          price - discount
        end

        #------------------------------------------------------------------------------
        def discount
          return Money.new(0, workshop.base_currency) if workshop_price.nil? || workshop_price.price.nil?

          cents = if discount_value.blank?
                    0
                  else
                    (discount_use_percent ? (workshop_price.price.cents * discount_value / 100) : (discount_value * 100))
                  end
          Money.new(cents, workshop_price.price.currency)
        end

        # Return the amount still owed, based on the current payments made.
        # balance_owed is positive if payment is still required.  Negative if there
        # has been an overpayment
        #------------------------------------------------------------------------------
        def balance_owed
          discounted_price - amount_paid
        end

        # suggested amount of next payment.
        # when it's recurring, they payment should be whatever is needed to bring their
        # payment plan up to date
        #------------------------------------------------------------------------------
        def payment_owed
          if workshop_price&.recurring_payments?
            to_pay = recurring_what_should_be_paid_by_now - amount_paid
            to_pay.negative? ? Money.new(0, workshop_price.price.currency) : to_pay
          else
            balance_owed
          end
        end

        # when a customer wants to make a payment, they should either charged the amount
        # for this month (which could be less than the normal monthly amount), or the
        # standard monthly amount, or whatever the balance_owed is
        #------------------------------------------------------------------------------
        def make_payment_now_amount
          if payment_owed.positive?
            payment_owed
          elsif workshop_price.payment_price < balance_owed
            workshop_price.payment_price
          else
            balance_owed
          end
        end

        # calculate what the actual date the initial payment should be.  Usually it's
        # date of registration.  However, we may wish for payments not to be required
        # until a certain date, either at the workshop or individual registration level
        #------------------------------------------------------------------------------
        def initial_payments_should_start_on
          if payment_reminder_hold_until
            payment_reminder_hold_until
          else
            workshop.initial_payment_required_on ? workshop.initial_payment_required_on : created_at
          end
        end

        #------------------------------------------------------------------------------
        def recurring_what_should_be_paid_by_now
          entry = workshop_price.specific_payment_schedule(initial_payments_should_start_on, Date.today)
          entry ? entry[:total_due] : 0
        end

        # date when the most recent payment was due
        #------------------------------------------------------------------------------
        def last_payment_due_on
          entry = workshop_price.specific_payment_schedule(initial_payments_should_start_on, Date.today)
          entry ? entry[:due_on] : initial_payments_should_start_on.to_date
        end

        # date when the most recent payment was made, or nil if no payments yet
        #------------------------------------------------------------------------------
        def last_payment_on
          payment_histories.try(:last).try(:payment_date)
        end

        #------------------------------------------------------------------------------
        def payment_schedule
          workshop_price ? workshop_price.payment_schedule(initial_payments_should_start_on) : []
        end

        # Payment was entered manually, create the history record.  You can tell it's
        # a manual entry if the user_profile is filled in - means a human did it.
        #------------------------------------------------------------------------------
        def manual_payment(payment_history, cost, total_currency, user_profile, options)
          options ||= { item_ref: '', payment_method: 'cash', bill_to_name: '', payment_date: Time.now,
                        notify_data: nil, transaction_id: nil, status: '' }
          amount = Monetize.parse(cost, total_currency)

          if payment_history
            new_amount_paid = amount_paid - workshop_price.to_base_currency(payment_history.total) + workshop_price.to_base_currency(amount)
            DmCore::PaymentHistories::UpdateService.call(payment_history, amount, user_profile, options)
          else
            new_amount_paid = amount_paid + workshop_price.to_base_currency(amount)
            payment_history = DmCore::PaymentHistories::CreateService.call(receipt_code, amount, user_profile, options)
            payment_histories << payment_history
          end

          if payment_history.errors.empty?
            update_attribute(:amount_paid_cents, new_amount_paid.cents)
            reload
            send('paid!') if balance_owed.cents <= 0 && accepted?
          else
            logger.error("===> Error: Registration.manual_payment: #{payment_history.errors.inspect}")
          end
          payment_history
        end

        # delete a payment and update the registrations total amount paid
        #------------------------------------------------------------------------------
        def delete_payment(payment_id)
          payment = PaymentHistory.find(payment_id)
          if payment
            update_attribute(:amount_paid_cents, (amount_paid - workshop_price.to_base_currency(payment.total)).cents)
            payment.destroy
            suppress_transition_email
            send('accept!') if balance_owed.positive? && paid?
            return true
          end
          false
        end

        # Return the payment page url, so that it can be used in emails
        #------------------------------------------------------------------------------
        def payment_url
          DmEvent::Engine.routes.url_helpers.register_choose_payment_url(uuid, host: Account.current.url_host, locale: I18n.locale)
        end

        #------------------------------------------------------------------------------
        def should_writeoff?
          writtenoff_on.nil? && balance_owed.positive? && workshop_price && (workshop_price.last_scheduled_payment_date(initial_payments_should_start_on).to_date + WRITE_OFF_DAYS.days) < Time.now
        end

        # writeoff the registration if it needs to
        #------------------------------------------------------------------------------
        def check_if_writeoff!
          should_writeoff? ? update_attribute(:writtenoff_on, Time.now) : false
        end
      end

      #------------------------------------------------------------------------------
      module ClassMethods
      end
    end
  end
end
