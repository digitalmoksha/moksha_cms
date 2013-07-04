# Note: The currency of a WorkshopPrice is the base currency of it's workshop.
# If they were different, we would need to always have an exchange rate available
# to convert to/from the workshop and the price currency.
# With the alternate price/currencies, the exchange rate is directly based on
# the prices in the two currencies.
#------------------------------------------------------------------------------
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
  monetize                :alt1_price_cents, :with_model_currency => :alt1_price_currency, :allow_nil => true
  monetize                :alt2_price_cents, :with_model_currency => :alt2_price_currency, :allow_nil => true

  include RankedModel
  ranks                   :row_order, :with_same => :workshop_id

  # --- globalize
  translates              :price_description, :sub_description, :payment_details, :fallbacks_for_empty_translations => true
  globalize_accessors     :locals => DmCore::Language.language_array

  validates_presence_of   :price_currency,      :if => Proc.new { |w| w.price_cents }
  validates_presence_of   :alt1_price_currency, :if => Proc.new { |w| w.alt1_price_cents }
  validates_presence_of   :alt2_price_currency, :if => Proc.new { |w| w.alt2_price_cents }
  validates_presence_of   :recurring_period,    :if => Proc.new { |w| w.recurring_amount }
  validates_presence_of   :recurring_number,    :if => Proc.new { |w| w.recurring_amount }

  CURRENCY_TYPES = {'British Pound (&pound;)'.html_safe => 'GBP',
                    'Czech Koruna (&#x4B;&#x10D;)'.html_safe => 'CZK',
                    'Euro (&euro;)'.html_safe => 'EUR',
                    'Indian Rupee (Rs)' => 'INR',
                    'Japanese Yen (&yen;)'.html_safe => 'JPY',
                    'Swiss Franc (Fr)' => 'CHF',
                    'US Dollar ($)' => 'USD' }
  PAYMENT_METHODS = ['Cash', 'Check', 'Credit Card', 'Money Order', 'PayPal', 'Wire Transfer']

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
