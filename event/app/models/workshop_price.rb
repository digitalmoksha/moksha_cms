# [todo] re-evaluate whether alternate currencies are really needed.  I can't
# think of a real use case at the moment, and it adds unnecessary complexity.
#
# Note: The currency of a WorkshopPrice is the base currency of it's workshop.
# If they were different, we would need to always have an exchange rate available
# to convert to/from the workshop and the price currency.
# With the alternate price/currencies, the exchange rate is directly based on
# the prices in the two currencies.
#------------------------------------------------------------------------------
class WorkshopPrice < ActiveRecord::Base

  self.table_name         = 'ems_workshop_prices'
  
  belongs_to              :workshop
  has_many                :registrations
  
  default_scope           { where(account_id: Account.current.id).order('row_order ASC') }

  # --- globalize
  translates              :price_description, :sub_description, :payment_details, fallbacks_for_empty_translations: true
  globalize_accessors     locales: DmCore::Language.language_array

  monetize                :price_cents, with_model_currency: :price_currency, allow_nil: true
  monetize                :alt1_price_cents, with_model_currency: :alt1_price_currency, allow_nil: true
  monetize                :alt2_price_cents, with_model_currency: :alt2_price_currency, allow_nil: true

  include RankedModel
  ranks                   :row_order, with_same: :workshop_id

  validates               :price_description, presence_default_locale: true
  validates               :payment_details, liquid: { locales: true }
  validates_presence_of   :price_currency,      if: Proc.new { |w| w.price_cents }
  validates_presence_of   :alt1_price_currency, if: Proc.new { |w| w.alt1_price_cents }
  validates_presence_of   :alt2_price_currency, if: Proc.new { |w| w.alt2_price_cents }
  validates_presence_of   :recurring_period,    if: Proc.new { |w| w.recurring_number }
  validates_presence_of   :recurring_number,    if: Proc.new { |w| w.recurring_period }

  PAYMENT_METHODS = ['Cash', 'Check', 'Credit Card', 'Money Order', 'PayPal', 'Wire Transfer']

  # For some reason, the initial monetized price gets created with the default
  # Money currency.  Need to use the current currency, as the internal fractional
  # value depends on it.  For example, 
  #  "15000".to_money('JPY').cents == 15000
  #  "15000".to_money('EUR').cents == 1500000
  # Call this method on the attributes before passing into new() or update_attributes()
  #------------------------------------------------------------------------------
  def self.prepare_prices(attributes = {})
    attributes['price']       = attributes['price'].to_money(attributes['price_currency']) if attributes['price'].present? && attributes['price_currency'].present?
    attributes['alt1_price']  = attributes['alt1_price'].to_money(attributes['alt1_price_currency']) if attributes['alt1_price'].present? && attributes['alt1_price_currency'].present?
    attributes['alt2_price']  = attributes['alt2_price'].to_money(attributes['alt2_price_currency']) if attributes['alt2_price'].present? && attributes['alt2_price_currency'].present?
    return attributes
  end
  
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
    price.nil? ? '' : price.format(no_cents_if_whole: true, symbol: true)
  end
  
  # returns the amount of a payment
  #------------------------------------------------------------------------------
  def payment_price
    recurring_payments? ? (price / recurring_number) : price
  end
  
  #------------------------------------------------------------------------------
  def recurring_payments?
    recurring_number.to_i > 1
  end
  
  #------------------------------------------------------------------------------
  def currency_list
    list = [[price_currency, price_currency]]
    list << [alt1_price_currency, alt1_price_currency] unless alt1_price_currency.blank?
    list << [alt2_price_currency, alt1_price_currency] unless alt1_price_currency.blank?
    return list
  end
  
  # Convert an amount in an alternate currency into the base currency
  #------------------------------------------------------------------------------
  def to_base_currency(money)
    bank.exchange_with(money, price_currency)
  end
  
  # return a bank object filled with the exchange rates, based on the prices.
  # then you can do:  bank.exchange_with(price, 'USD')
  #------------------------------------------------------------------------------
  def bank
    unless @bank
      @bank = Money::Bank::VariableExchange.new
      unless alt1_price_currency.blank?
        @bank.add_rate(price_currency, alt1_price_currency, alt1_price_cents.to_f / price_cents.to_f)
        @bank.add_rate(alt1_price_currency, price_currency, price_cents.to_f / alt1_price_cents.to_f)
      end
      unless alt2_price_currency.blank?
        @bank.add_rate(price_currency, alt2_price_currency, alt2_price_cents.to_f / price_cents.to_f)
        @bank.add_rate(alt2_price_currency, price_currency, price_cents.to_f / alt2_price_cents.to_f)
      end
      unless alt1_price_currency.blank? && alt2_price_currency.blank?
        @bank.add_rate(alt1_price_currency, alt2_price_currency, alt2_price_cents.to_f / alt1_price_cents.to_f)
        @bank.add_rate(alt2_price_currency, alt1_price_currency, alt1_price_cents.to_f / alt2_price_cents.to_f)
      end
    end
    return @bank
  end
  
end