class WorkshopPrice < ActiveRecord::Base

  self.table_name         = 'ems_workshop_prices'
  
  attr_accessible         :workshop_id, :price_desc, :sub_description,
                          :disable, :valid_until, :valid_starting_on, :total_available,
                          :price, :price_cents, :price_currency, 
                          :alt1_price, :alt1_price_cents, :alt1_price_currency, 
                          :alt2_price, :alt2_price_cents, :alt2_price_currency
  
  belongs_to              :workshop

  default_scope           { where(account_id: Account.current.id).order('row_order ASC') }

  monetize                :price_cents, :with_model_currency => :price_currency, :allow_nil => true
  monetize                :alt1_price_cents, :allow_nil => true
  monetize                :alt2_price_cents, :allow_nil => true

  include RankedModel
  ranks                   :row_order, :with_same => :workshop_id

  CURRENCY_TYPES = { 'EUR' => 'EUR', 'CHF' => 'CHF', 'GBP' => 'GBP', 'USD' => 'USD' }

  #------------------------------------------------------------------------------
  def visible?
    !(disable? || (!valid_starting_on.nil? && valid_starting_on > Time.now.to_date) || (!valid_until.nil? && valid_until < Time.now.to_date))
  end
 
  # If the total_available is nil, then there are unlimited tickets to be sold.  
  # Otherwise, check if we have sold out
  #------------------------------------------------------------------------------
  def sold_out?(num_sold)
    (total_available.blank? or total_available == 0) ? false : (num_sold >= total_available)
  end
  
  # @@uclogger = Logger.new(File.join(File.expand_path(Rails.root), "log", "ultracart_ipn.log"))

  #------------------------------------------------------------------------------
  # def currency_list
  #   list = [[country.currency_code, country.id]]
  #   list << [alt1_country.currency_code, alt1_country.id] unless alt1_country.blank?
  #   list << [alt2_country.currency_code, alt2_country.id] unless alt2_country.blank?
  #   return list
  # end
  
  # # Convert an amount in an alternate currency into the base currency
  # #------------------------------------------------------------------------------
  # def to_base_currency_cents(alternate_cents, currency)
  #   (alternate_cents * exchange_rate(currency)).to_i
  # end
  # 
  # # Convert an amount in the base currency into an alternate currency
  # #------------------------------------------------------------------------------
  # def to_alt_currency_cents(base_price_cents, currency)
  #   (base_price_cents / exchange_rate(currency)).to_i
  # end
  # 
  # # Calculate the current exchange rate, between the base currency and the 
  # # specified alternate currency.  base_price/alternate_price
  # #------------------------------------------------------------------------------
  # def exchange_rate(currency)
  #   if alt1_price_currency == currency
  #     return (price.to_f * 100) / (alt1_price.to_f * 100)
  #   elsif alt2_price_currency == currency
  #     return (price.to_f * 100) / (alt2_price.to_f * 100)
  #   else
  #     return 1.to_f
  #   end    
  # end
  
  # # for converting a payment into total cents
  # #------------------------------------------------------------------------------
  # def self.payment_total_cents(cost, quantity = 1, discount = 0)
  #   (cost.to_f * 100).to_i * quantity - (discount.to_f * 100).to_i
  # end
  
  # # This function is called by UltraCart when an item is purchased from the online
  # # store.  The entire order is sent.  Initially, we will look for the 
  # # registration code we place in a ticket order, and mark the appropriate record
  # # as payed in the database.  But this also sets up the possibility of keeping
  # # our own purchase records and doing our own reporting.
  # #------------------------------------------------------------------------------
  # def self.verify_payment(current_account, params)
  #   #--- the specifics for order have already been parsed into the params block
  #   notify  = Ultracart::Notification.new(params)
  #   @@uclogger.info(Time.now.utc.to_s + ": Order ID => #{notify.order_details['order_id']}  " +
  #                   "Stage => #{notify.order_details['current_stage']} " +
  #                   "Name => #{notify.order_details['bill_to_first_name']} #{notify.order_details['bill_to_last_name']}"
  #                   )
  # 
  #   receipts      = Array.new
  # 
  #   #--- validate the merchant id
  #   if notify.order_details['merchant_id'] != current_account.preferred(:ultracart_merchant_id)
  #     @@uclogger.info("  ==> Error: merchant_id incorrect: #{notify.order_details['merchant_id']} != #{current_account.preferred(:ultracart_merchant_id)}")
  #     @@uclogger.info(params.inspect)
  #   else
  #     case notify.current_stage
  #     when :pre_order, :account_receivable, :shipping, :rejected
  #       @@uclogger.info("  Ignored")
  #       #--- these are just notifications - do nothing
  #     when :completed_order
  #       #--- iterate over each item in order
  #       notify.items.each_with_index do |item, i|
  #         #--- only record notifications that have a registration code
  #         unless notify.anchor_ids[i].blank?
  #           history = PaymentHistory.create(:notify => notify, :item => item, :anchor_id => notify.anchor_ids[i])
  #           history.update_attribute(:total_cents, EventPayment.payment_total_cents(history.cost, history.quantity, history.discount))
  #           history.update_attribute(:owner_type, 'EventRegistration')
  #           history.update_attribute(:owner_id, EventRegistration.receiptcode_to_id(history.anchor_id))
  #           @@uclogger.info("  item_id => #{history.item_id}  anchor_id => #{history.anchor_id}")
  # 
  #           if history.anchor_id
  #             #--- check if there is a valid user
  #             event = EventRegistration.find_by_receiptcode(history.anchor_id)
  #             if event.nil?
  #               @@uclogger.info("  ==> Error: invalid registration id => #{history.anchor_id}")
  #               @@uclogger.info(params.inspect)
  #             else
  #               history.update_attribute(:currency_country_id, event.event_payment.country_id) 
  #               event.mark_paid(history.total_cents)
  #               event.add_comment(Comment.new(:comment => "[coupon_code: #{history.coupon_code}] ")) unless history.coupon_code.blank?
  #               receipts << {:receiptcode => history.anchor_id, :cost_cents => history.total_cents, :description => history.item_name}
  #             end
  #           end
  #         end
  #       end
  #     end
  #   end
  # 
  #   return receipts
  # end
end


#--- Sample XML lines for testing verify_payment function
#x = {"export"=>{"export_location"=>"accounts receivable", "order"=>{"surcharge_accounting_code"=>{}, "ship_to_state"=>{}, "gift_charge_accounting_code"=>{}, "total"=>"0.00", "bill_to_country"=>"United States", "surcharge_transaction_fee"=>"0.00", "shipping_date_time"=>"22 MAR 2006 19:49:42", "order_id"=>"DEVA9-200603221949-422385", "payment_method_accounting_code"=>{}, "subtotal"=>"0.00", "card_number"=>{}, "card_exp_month"=>"1", "merchant_id"=>"DEVA9", "shipping_method"=>{}, "payment_date_time"=>"22 MAR 2006 19:47:23", "advertising_source"=>{}, "tax_county_accounting_code"=>{}, "tax_postal_code_accounting_code"=>{}, "ship_to_country"=>{}, "shipping_date"=>"03/22/2006", "card_type"=>"Visa", "weight"=>"0.00000 LB", "tax_rate"=>"0.00000", "bill_to_company"=>{}, "merchant_notes"=>{}, "email"=>"walkerbl@mail.com", "order_date"=>"22 MAR 2006 19:49:42", "ship_to_city"=>{}, "shipping_tracking_number"=>{}, "payment_method_deposit_to_account"=>{}, "payment_date"=>"03/22/2006", "bill_to_address1"=>"15450 FM 1325 #2728", "bill_to_last_name"=>"Walker", "gift_wrap_accounting_code"=>{}, "day_phone"=>"512-238-9870", "evening_phone"=>{}, "bill_to_address2"=>{}, "payment_method"=>"Credit Card", "bill_to_zip"=>"78728", "ship_to_address1"=>{}, "bill_to_city"=>"Austin", "tax"=>"0.00", "special_instructions"=>{}, "ship_to_address2"=>{}, "ship_to_company"=>{}, "ship_to_first_name"=>{}, "ship_to_zip"=>{}, "subtotal_discount"=>"0.00", "gift"=>"no", "shipping_handling_total"=>"0.00", "referral_code"=>{}, "fax"=>{}, "tax_city_accounting_code"=>{}, "card_exp_year"=>"1999", "shipping_method_accounting_code"=>{}, "current_stage"=>"CO", "surcharge_transaction_percentage"=>"0.0000", "bill_to_first_name"=>"Brett", "bill_to_state"=>"TX", "item"=>[{"tax_free"=>"true", "item_id"=>"DEVATR-SPECIAL-5000", "merchant_id"=>"DEVA9", "discount"=>"0.00", "order_id"=>"DEVA9-200603221949-422385", "cost"=>"5000.00", "option"=>{"option_value"=>"DGER-1123", "item_id"=>"DEVATR-SPECIAL-5000", "merchant_id"=>"DEVA9", "order_id"=>"DEVA9-200603221949-422385", "weight_change"=>"0.00000 LB", "cost_change"=>"0.00", "item_index"=>"1", "option_id"=>"11066", "option_name"=>{}}, "item_weight"=>"0.00000 LB", "quantity"=>"1", "accounting_code"=>"DEVATR-ATMALINGAM", "free_shipping"=>"false", "special_product_type"=>{}, "distribution_center_code"=>"NOVA", "description"=>"Special Process Discussion 5000", "item_index"=>"1"}, {"tax_free"=>"true", "item_id"=>"DEVATR-SPECIAL-9000", "merchant_id"=>"DEVA9", "discount"=>"0.00", "order_id"=>"DEVA9-200603221949-422385", "cost"=>"9000.00", "option"=>{"option_value"=>"DGER-1124", "item_id"=>"DEVATR-SPECIAL-9000", "merchant_id"=>"DEVA9", "order_id"=>"DEVA9-200603221949-422385", "weight_change"=>"0.00000 LB", "cost_change"=>"0.00", "item_index"=>"2", "option_id"=>"11039", "option_name"=>{}}, "item_weight"=>"0.00000 LB", "quantity"=>"1", "accounting_code"=>"DEVATR-SPECIAL-9000", "free_shipping"=>"false", "special_product_type"=>{}, "distribution_center_code"=>"NOVA", "description"=>"Special Process Discussion 9000", "item_index"=>"2"}], "surcharge"=>"0.00", "shipping_handling_total_discount"=>"0.00", "tax_county"=>{}, "order_type"=>"credit card", "ship_to_last_name"=>{}, "card_auth_ticket"=>{}, "tax_country_accounting_code"=>{}, "tax_state_accounting_code"=>{}}}}
#y = {"export"=>{"export_location"=>"accounts receivable", "order"=>{"surcharge_accounting_code"=>{}, "ship_to_state"=>{}, "gift_charge_accounting_code"=>{}, "total"=>"0.00", "bill_to_country"=>"United States", "surcharge_transaction_fee"=>"0.00", "shipping_date_time"=>"22 MAR 2006 21:18:44", "order_id"=>"DEVA9-200603222118-433747", "payment_method_accounting_code"=>{}, "subtotal"=>"0.00", "card_number"=>{}, "card_exp_month"=>"1", "merchant_id"=>"DEVA9", "shipping_method"=>{}, "payment_date_time"=>"22 MAR 2006 21:16:25", "advertising_source"=>{}, "tax_county_accounting_code"=>{}, "tax_postal_code_accounting_code"=>{}, "ship_to_country"=>{}, "shipping_date"=>"03/22/2006", "card_type"=>"Visa", "weight"=>"0.00000 LB", "tax_rate"=>"0.00000", "bill_to_company"=>{}, "merchant_notes"=>{}, "email"=>"walkerbl@mail.com", "order_date"=>"22 MAR 2006 21:18:43", "ship_to_city"=>{}, "shipping_tracking_number"=>{}, "payment_method_deposit_to_account"=>{}, "payment_date"=>"03/22/2006", "bill_to_address1"=>"15450 FM 1325 #2728", "bill_to_last_name"=>"Walker", "gift_wrap_accounting_code"=>{}, "day_phone"=>"512-238-9870", "evening_phone"=>{}, "bill_to_address2"=>{}, "payment_method"=>"Credit Card", "bill_to_zip"=>"78728", "ship_to_address1"=>{}, "bill_to_city"=>"Austin", "tax"=>"0.00", "special_instructions"=>{}, "ship_to_address2"=>{}, "ship_to_company"=>{}, "ship_to_first_name"=>{}, "ship_to_zip"=>{}, "subtotal_discount"=>"0.00", "gift"=>"no", "shipping_handling_total"=>"0.00", "referral_code"=>{}, "fax"=>{}, "tax_city_accounting_code"=>{}, "card_exp_year"=>"1999", "shipping_method_accounting_code"=>{}, "current_stage"=>"CO", "surcharge_transaction_percentage"=>"0.0000", "bill_to_first_name"=>"Brett", "bill_to_state"=>"TX", "item"=>{"merchant_id"=>"DEVA9", "item_id"=>"DEVATR-BRAHMA", "tax_free"=>"true", "order_id"=>"DEVA9-200603222118-433747", "discount"=>"0.00", "cost"=>"0.00", "option"=>{"merchant_id"=>"DEVA9", "item_id"=>"DEVATR-BRAHMA", "option_value"=>"DGER-12", "order_id"=>"DEVA9-200603222118-433747", "weight_change"=>"0.00000 LB", "item_index"=>"1", "cost_change"=>"0.00", "option_id"=>"11039", "option_name"=>{}}, "quantity"=>"1", "item_weight"=>"0.00000 LB", "special_product_type"=>{}, "free_shipping"=>"false", "accounting_code"=>"DEVATR-BRAHMA", "item_index"=>"1", "description"=>"Brahma Consciousness Discussion Group", "distribution_center_code"=>"NOVA"}, "surcharge"=>"0.00", "shipping_handling_total_discount"=>"0.00", "tax_county"=>{}, "order_type"=>"credit card", "ship_to_last_name"=>{}, "card_auth_ticket"=>{}, "tax_country_accounting_code"=>{}, "tax_state_accounting_code"=>{}}}}
#z = {"export"=>{"export_location"=>"accounts receivable", "order"=>{"surcharge_accounting_code"=>{}, "ship_to_state"=>{}, "gift_charge_accounting_code"=>{}, "total"=>"0.00", "bill_to_country"=>"United States", "surcharge_transaction_fee"=>"0.00", "shipping_date_time"=>"22 MAR 2006 21:18:44", "order_id"=>"DEVA9-200603222118-433747", "payment_method_accounting_code"=>{}, "subtotal"=>"0.00", "card_number"=>{}, "card_exp_month"=>"1", "merchant_id"=>"DEVA9", "shipping_method"=>{}, "payment_date_time"=>"22 MAR 2006 21:16:25", "advertising_source"=>{}, "tax_county_accounting_code"=>{}, "tax_postal_code_accounting_code"=>{}, "ship_to_country"=>{}, "shipping_date"=>"03/22/2006", "card_type"=>"Visa", "weight"=>"0.00000 LB", "tax_rate"=>"0.00000", "bill_to_company"=>{}, "merchant_notes"=>{}, "email"=>"walkerbl@mail.com", "order_date"=>"22 MAR 2006 21:18:43", "ship_to_city"=>{}, "shipping_tracking_number"=>{}, "payment_method_deposit_to_account"=>{}, "payment_date"=>"03/22/2006", "bill_to_address1"=>"15450 FM 1325 #2728", "bill_to_last_name"=>"Walker", "gift_wrap_accounting_code"=>{}, "day_phone"=>"512-238-9870", "evening_phone"=>{}, "bill_to_address2"=>{}, "payment_method"=>"Credit Card", "bill_to_zip"=>"78728", "ship_to_address1"=>{}, "bill_to_city"=>"Austin", "tax"=>"0.00", "special_instructions"=>{}, "ship_to_address2"=>{}, "ship_to_company"=>{}, "ship_to_first_name"=>{}, "ship_to_zip"=>{}, "subtotal_discount"=>"0.00", "gift"=>"no", "shipping_handling_total"=>"0.00", "referral_code"=>{}, "fax"=>{}, "tax_city_accounting_code"=>{}, "card_exp_year"=>"1999", "shipping_method_accounting_code"=>{}, "current_stage"=>"CO", "surcharge_transaction_percentage"=>"0.0000", "bill_to_first_name"=>"Brett", "bill_to_state"=>"TX", "item"=>{"merchant_id"=>"DEVA9", "item_id"=>"DEVATR-BRAHMA", "tax_free"=>"true", "order_id"=>"DEVA9-200603222118-433747", "discount"=>"0.00", "cost"=>"0.00", "quantity"=>"1", "item_weight"=>"0.00000 LB", "special_product_type"=>{}, "free_shipping"=>"false", "accounting_code"=>"DEVATR-BRAHMA", "item_index"=>"1", "description"=>"Brahma Consciousness Discussion Group", "distribution_center_code"=>"NOVA"}, "surcharge"=>"0.00", "shipping_handling_total_discount"=>"0.00", "tax_county"=>{}, "order_type"=>"credit card", "ship_to_last_name"=>{}, "card_auth_ticket"=>{}, "tax_country_accounting_code"=>{}, "tax_state_accounting_code"=>{}}}}
#x = {"export"=>{"export_location"=>"accounts receivable", "order"=>{"surcharge_accounting_code"=>{}, "ship_to_state"=>{}, "gift_charge_accounting_code"=>{}, "total"=>"0.00", "bill_to_country"=>"United States", "surcharge_transaction_fee"=>"0.00", "shipping_date_time"=>"22 MAR 2006 19:49:42", "order_id"=>"DEVA9-200603221949-422385", "payment_method_accounting_code"=>{}, "subtotal"=>"0.00", "card_number"=>{}, "card_exp_month"=>"1", "merchant_id"=>"DEVA9", "shipping_method"=>{}, "payment_date_time"=>"22 MAR 2006 19:47:23", "advertising_source"=>{}, "tax_county_accounting_code"=>{}, "tax_postal_code_accounting_code"=>{}, "ship_to_country"=>{}, "shipping_date"=>"03/22/2006", "card_type"=>"Visa", "weight"=>"0.00000 LB", "tax_rate"=>"0.00000", "bill_to_company"=>{}, "merchant_notes"=>{}, "email"=>"walkerbl@mail.com", "order_date"=>"22 MAR 2006 19:49:42", "ship_to_city"=>{}, "shipping_tracking_number"=>{}, "payment_method_deposit_to_account"=>{}, "payment_date"=>"03/22/2006", "bill_to_address1"=>"15450 FM 1325 #2728", "bill_to_last_name"=>"Walker", "gift_wrap_accounting_code"=>{}, "day_phone"=>"512-238-9870", "evening_phone"=>{}, "bill_to_address2"=>{}, "payment_method"=>"Credit Card", "bill_to_zip"=>"78728", "ship_to_address1"=>{}, "bill_to_city"=>"Austin", "tax"=>"0.00", "special_instructions"=>{}, "ship_to_address2"=>{}, "ship_to_company"=>{}, "ship_to_first_name"=>{}, "ship_to_zip"=>{}, "subtotal_discount"=>"0.00", "gift"=>"no", "shipping_handling_total"=>"0.00", "referral_code"=>{}, "fax"=>{}, "tax_city_accounting_code"=>{}, "card_exp_year"=>"1999", "shipping_method_accounting_code"=>{}, "current_stage"=>"CO", "surcharge_transaction_percentage"=>"0.0000", "bill_to_first_name"=>"Brett", "bill_to_state"=>"TX", "item"=>[{"tax_free"=>"true", "item_id"=>"DEVATR-SPECIAL-5000", "merchant_id"=>"DEVA9", "discount"=>"0.00", "order_id"=>"DEVA9-200603221949-422385", "cost"=>"5000.00", "option"=>{"option_value"=>"DGER-1112", "item_id"=>"DEVATR-SPECIAL-5000", "merchant_id"=>"DEVA9", "order_id"=>"DEVA9-200603221949-422385", "weight_change"=>"0.00000 LB", "cost_change"=>"0.00", "item_index"=>"1", "option_id"=>"11066", "option_name"=>{}}, "item_weight"=>"0.00000 LB", "quantity"=>"1", "accounting_code"=>"DEVATR-ATMALINGAM", "free_shipping"=>"false", "special_product_type"=>{}, "distribution_center_code"=>"NOVA", "description"=>"Special Process Discussion 5000", "item_index"=>"1"}, {"tax_free"=>"true", "item_id"=>"DEVATR-SPECIAL-9000", "merchant_id"=>"DEVA9", "discount"=>"0.00", "order_id"=>"DEVA9-200603221949-422385", "cost"=>"9000.00", "option"=>{"option_value"=>"DGER-1108", "item_id"=>"DEVATR-SPECIAL-9000", "merchant_id"=>"DEVA9", "order_id"=>"DEVA9-200603221949-422385", "weight_change"=>"0.00000 LB", "cost_change"=>"0.00", "item_index"=>"2", "option_id"=>"11039", "option_name"=>{}}, "item_weight"=>"0.00000 LB", "quantity"=>"1", "accounting_code"=>"DEVATR-SPECIAL-9000", "free_shipping"=>"false", "special_product_type"=>{}, "distribution_center_code"=>"NOVA", "description"=>"Special Process Discussion 9000", "item_index"=>"2"}], "surcharge"=>"0.00", "shipping_handling_total_discount"=>"0.00", "tax_county"=>{}, "order_type"=>"credit card", "ship_to_last_name"=>{}, "card_auth_ticket"=>{}, "tax_country_accounting_code"=>{}, "tax_state_accounting_code"=>{}}}}
#items = x["order"]["item"]

#x = {"export"=>{"export_location"=>"accounts receivable", "order"=>{"surcharge_accounting_code"=>nil, "ship_to_state"=>nil, "gift_charge_accounting_code"=>nil, "total"=>"1499.00", "bill_to_country"=>"Germany", "surcharge_transaction_fee"=>"0.00", "shipping_date_time"=>"26 AUG 2006 16:37:02", "order_id"=>"DEVA9-200608261636-599131", "payment_method_accounting_code"=>nil, "subtotal"=>"1499.00", "card_number"=>"5415-5601-7009-0014", "card_exp_month"=>"6", "merchant_id"=>"DEVA9", "shipping_method"=>nil, "payment_date_time"=>"26 AUG 2006 16:37:02", "advertising_source"=>nil, "tax_county_accounting_code"=>nil, "mailing_list"=>"Y", "tax_postal_code_accounting_code"=>nil, "ship_to_country"=>nil, "shipping_date"=>"08/26/2006", "card_type"=>"MasterCard", "weight"=>"0.00000 LB", "tax_rate"=>"0.00000", "bill_to_company"=>nil, "merchant_notes"=>nil, "email"=>"lotuscrystal@gmx.de", "order_date"=>"26 AUG 2006 16:37:01", "ship_to_city"=>nil, "shipping_tracking_number"=>nil, "payment_method_deposit_to_account"=>nil, "payment_date"=>"08/26/2006", "bill_to_address1"=>"Am Anger 20", "bill_to_last_name"=>"Burkhart", "gift_wrap_accounting_code"=>nil, "day_phone"=>"++49 8667 / 879114", "evening_phone"=>"++49 176 25301101", "bill_to_address2"=>"Arlaching", "payment_method"=>"Credit Card", "bill_to_zip"=>"83339", "ship_to_address1"=>nil, "bill_to_city"=>"Chieming", "tax"=>"0.00", "special_instructions"=>nil, "ship_to_address2"=>nil, "ship_to_company"=>nil, "ship_to_first_name"=>nil, "ship_to_zip"=>nil, "subtotal_discount"=>"0.00", "gift"=>"no", "shipping_handling_total"=>"0.00", "referral_code"=>nil, "fax"=>nil, "tax_city_accounting_code"=>nil, "card_exp_year"=>"2008", "shipping_method_accounting_code"=>nil, "current_stage"=>"CO", "surcharge_transaction_percentage"=>"0.0000", "bill_to_first_name"=>"Patricia Sakini", "bill_to_state"=>"BAVARIA", "item"=>{"merchant_id"=>"DEVA9", "item_id"=>"DEVATR-DEC2006", "tax_free"=>"true", "order_id"=>"DEVA9-200608261636-599131", "discount"=>"0.00", "cost"=>"1499.00", "option"=>{"merchant_id"=>"DEVA9", "item_id"=>"DEVATR-DEC2006", "option_value"=>"DGER-5018", "order_id"=>"DEVA9-200608261636-599131", "weight_change"=>"0.00000 LB", "item_index"=>"1", "cost_change"=>"0.00", "option_id"=>"13863", "option_name"=>nil}, "quantity"=>"1", "item_weight"=>"0.00000 LB", "special_product_type"=>nil, "free_shipping"=>"false", "accounting_code"=>"DEVATR-DEC2006", "item_index"=>"1", "description"=>"Weekend with Sri Kaleshwar at the Joshua Tree, Dec 2006", "distribution_center_code"=>"NOVA"}, "surcharge"=>"0.00", "shipping_handling_total_discount"=>"0.00", "tax_county"=>nil, "order_type"=>"credit card", "ship_to_last_name"=>nil, "card_auth_ticket"=>"657579", "tax_state_accounting_code"=>nil, "tax_country_accounting_code"=>nil}}}


