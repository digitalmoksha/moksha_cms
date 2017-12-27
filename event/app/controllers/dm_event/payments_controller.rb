ActionView::Base.send(:include, OffsitePayments::ActionViewHelper)

class DmEvent::PaymentsController < DmEvent::ApplicationController
  include OffsitePayments::Integrations

  protect_from_forgery except: [:paypal_ipn, :sofort_ipn], prepend: true

  # TODO Not fully working yet
  #------------------------------------------------------------------------------
  def paypal_ipn
    logger.error('===> Enter: controller::paypal_ipn')
    notify = Paypal::Notification.new(request.raw_post)
    Payment.event_payment_ipn(notify, 'paypal')

    head :ok
  end

  # TODO Not fully working yet
  #------------------------------------------------------------------------------
  def sofort_ipn
    logger.error('===> Enter: controller::sofort_ipn')
    notify = Directebanking::Notification.new(request.raw_post, credential4: current_account.preferred_sofort_notification_password)
    Payment.event_payment_ipn(notify, 'sofort')

    head :ok
  end

end
