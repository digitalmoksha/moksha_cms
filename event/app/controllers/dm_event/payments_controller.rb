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



=begin
  include         Ultracart::UltracartHelper

  # This function is called by UltraCart when an item is purchased from the online
  # store.  The entire order is sent.  Initially, we will look for the
  # registration code we place in a ticket order, and mark the appropriate record
  # as payed in the database.  But this also sets up the possibility of keeping
  # our own records purchase records and doing our own reporting.
  #------------------------------------------------------------------------------
  def verify_payment
    #--- the specifics for order have already been parsed into the params block
    receipts = EventPayment.verify_payment(current_account, params)

    receipts.each do |r|
      begin
        email_receipt(EventRegistration.receiptcode_to_id(r[:receiptcode]), r[:cost_cents], r[:description])
      rescue Exception => e
        #--- if there is a problem sending the receipt, we should send place it on a queue for
        #--- sending later TODO.  But we need to do the render below so that Ultracart
        #--- doesn't send the notification again.
      end
    end

    head :ok
  end

  #------------------------------------------------------------------------------
  def generate_shoppingcart_link(registration)
    anchor_id = PaymentHistory.generate_anchor_id(registration.receiptcode)
    item_options = [{:name => 'registration_code', :value => anchor_id}]
    options = {
      :MerchantID                   => current_account.preferred(:ultracart_merchant_id),
      :ThemeCode                    => current_account.preferred(:ultracart_theme_code),
      :BillingFirstName             => registration.firstname,
      :BillingLastName              => registration.lastname,
      :BillingAddress1              => registration.address,
      :BillingAddress2              => registration.address2,
      :BillingCity                  => registration.city,
      :BillingState                 => registration.state,
      :BillingPostalCode            => registration.zipcode,
      :BillingCountry               => registration.country.english_name,
      :BillingDayPhone              => registration.phone,
      :Email                        => registration.email,
      :OVERRIDECATALOGURL           => current_account.preferred(:ultracart_continue_shopping_url),
      :OVERRIDECONTINUESHOPPINGURL  => current_account.preferred(:ultracart_continue_shopping_url),
      :item_options                 => item_options
    }
    options[:ImmediateCheckout] = true if registration.event_workshop.shoppingcart_immediate_checkout

    url_for_ultracart(registration.item_code, Ultracart::Config.cart_url, true, options)
  end
=end
