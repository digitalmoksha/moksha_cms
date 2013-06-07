class WorkshopPrice < ActiveRecord::Base

  self.table_name         = 'ems_workshop_prices'
  
  attr_accessible         :workshop_id, :price_description, :sub_description, :payment_details,
                          :disabled, :valid_until, :valid_starting_on, :total_available,
                          :price, :price_cents, :price_currency, 
                          :alt1_price, :alt1_price_cents, :alt1_price_currency, 
                          :alt2_price, :alt2_price_cents, :alt2_price_currency,
                          :recurring_amount, :recurring_period, :recurring_number
  
  belongs_to              :workshop

  default_scope           { where(account_id: Account.current.id).order('row_order ASC') }

  monetize                :price_cents, :with_model_currency => :price_currency, :allow_nil => true
  monetize                :alt1_price_cents, :allow_nil => true
  monetize                :alt2_price_cents, :allow_nil => true

  include RankedModel
  ranks                   :row_order, :with_same => :workshop_id

  # --- globalize
  translates              :price_description, :sub_description, :payment_details, :fallbacks_for_empty_translations => true
  globalize_accessors     :locals => DmCore::Language.language_array

  CURRENCY_TYPES = { 'EUR' => 'EUR', 'CHF' => 'CHF', 'GBP' => 'GBP', 'CZK' => 'CZK', 'USD' => 'USD', 'JPY' => 'JPY', 'INR' => 'INR' }

  #------------------------------------------------------------------------------
  def visible?
    !(disabled? || (!valid_starting_on.nil? && valid_starting_on > Time.now.to_date) || (!valid_until.nil? && valid_until < Time.now.to_date))
  end
 
  # If the total_available is nil, then there are unlimited tickets to be sold.  
  # Otherwise, check if we have sold out
  #------------------------------------------------------------------------------
  def sold_out?(num_sold)
    (total_available.blank? or total_available == 0) ? false : (num_sold >= total_available)
  end
  
  #------------------------------------------------------------------------------
  def price_formatted
    price.format(:no_cents_if_whole => true, :symbol => true)
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

end
