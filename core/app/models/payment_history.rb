# anchor_id        =>  unique number tying paid item to our item
# order_ref        =>  order number
# item_ref         =>  specfic item number
# item_name        =>  item's name
# quantity         =>  number of items
# cost             =>  cost of item, as a string
# discount         =>  any coupon/dicsount
# total_cents      =>  total amount in cents
# total_currency   =>  currency 3 char code
# payment_method   =>  how payment was made: cash, credit card, etc
# payment_date     =>  date of payment
# bill_to_name     =>  who actually paid / was billed to
# item_details     =>  any specific item details sent by payment processor
# order_details    =>  any specific order details sent by payment processor
# current_stage    =>  current stage of payment
# user_profile_id  =>  user_profile if payment was enetered manually
#------------------------------------------------------------------------------
class PaymentHistory < ActiveRecord::Base

  self.table_name         = 'core_payment_histories'

  attr_accessible           :anchor_id, :item_ref, :cost, :quantity, :discount,
                            :total_cents, :total_currency, :payment_method, :bill_to_name,
                            :payment_date, :user_profile_id
  belongs_to                :owner, :polymorphic => true
  belongs_to                :user_profile
  serialize                 :order_details
  serialize                 :item_details
  monetize                  :total_cents, :with_model_currency => :total_currency, :allow_nil => true

  default_scope             { where(account_id: Account.current.id) }

  validates_numericality_of :cost

  # This will get overridden by any specilized integrations, such as Ultracart
  #------------------------------------------------------------------------------
  def initialize(params, options)
    super(params, options)
  end

  # Generate the anchor code that gets placed in a shopping cart item.  This is
  # used to gain access to some agreed upon item in the database.
  # Default algorithm: Use the current time as a unique code and append
  # the passed in id
  # Ex: ANC-1158569928-517
  # -> override this function to provide a different algorithm if needed
  #------------------------------------------------------------------------------
  def self.generate_anchor_id(id)
    "ANC-#{Time.now.utc.to_i}-#{id}"
  end

  # Extract the anchor code that gets placed in a shopping cart item.  This is
  # used to gain access to some agreed upon item in the database.
  # Default algorithm: Use the current time as a unique code and append
  # the passed in id
  # -> override this function to provide a different algorithm if needed
  #------------------------------------------------------------------------------
  def self.extract_anchor_id(anchor_id)
    #--- pull off first two pieces, and put rest back together if there were any 
    #    embedded dashes
    values = anchor_id.split('-')
    return values.slice(2, 10).join('-')
  end
end
