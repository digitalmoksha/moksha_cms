# Handle payment related logic
#------------------------------------------------------------------------------
class Payment
  include OffsitePayments::Integrations

  # Handle Payment notification logic
  #------------------------------------------------------------------------------
  def self.event_payment_ipn(notify, payment_method = '')
    Rails.logger.error('===> Enter: Payment.event_payment_ipn')
    Rails.logger.error(notify.inspect)
    registration = Registration.find_by_receipt_code(notify.item_id)

    if notify.acknowledge
      if registration
        Rails.logger.error(registration.inspect)
        payment_history = PaymentHistory.find_by_transaction_id(notify.transaction_id) ||
                            registration.manual_payment(nil,
                                                        notify.amount.to_f.to_s,
                                                        notify.currency,
                                                        nil,
                                                        payment_method: payment_method,
                                                        payment_date: notify.received_at,
                                                        notify_data: notify,
                                                        transaction_id: notify.transaction_id,
                                                        status: notify.status
                                                       )
          Rails.logger.error(payment_history.inspect)
        begin
          if notify.complete?
            payment_history.status = notify.status
          else
            # TODO need to handle refunding, etc
            Rails.logger.error("Failed to verify #{payment_method} payment notification, please investigate")
          end
        rescue => e
          payment_history.status = 'Error'
          raise
        ensure
          payment_history.save
        end
      else
        #--- [todo] a linked registration was not found.  Should be stored in payment table anyway
        Rails.logger.error("   > Error: Registration was not found: #{notify.item_id}")
      end
    end
  end
end