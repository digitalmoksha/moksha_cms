class CreatePaymentHistory < ActiveRecord::Migration
  def up
    create_table :core_payment_histories, :force => true do |t|
      t.integer  :owner_id
      t.string   :owner_type,      :limit => 30
      t.integer  :anchor_id                       # unique number tying paid item to our item
      t.string   :order_ref                       # order number
      t.string   :item_ref                        # specfic item number
      t.string   :item_name                       # item's name
      t.integer  :quantity                        # number of items
      t.string   :cost                            # cost of item, as a string
      t.string   :discount                        # any coupon/dicsount
      t.integer  :total_cents                     # total amount in cents
      t.string   :total_currency,  :limit => 3    # currency 3 char code
      t.string   :payment_method                  # how payment was made: cash, credit card, etc
      t.datetime :payment_date                    # date of payment
      t.string   :bill_to_name                    # who actually paid / was billed to
      t.text     :item_details                    # any specific item details sent by payment processor
      t.text     :order_details                   # any specific order details sent by payment processor
      t.string   :current_stage                   # current stage of payment
      t.integer  :user_profile_id                 # user_profile if payment was enetered manually
      t.datetime :created_on
      t.integer  :account_id
    end

    add_index "core_payment_histories", ["anchor_id"], :name => "index_payment_histories_on_anchor_id"
    add_index "core_payment_histories", ["item_ref"], :name => "index_payment_histories_on_item_ref"
    add_index "core_payment_histories", ["order_ref"], :name => "index_payment_histories_on_order_ref"
    add_index "core_payment_histories", ["owner_id"], :name => "index_payment_histories_on_owner_id"
    add_index "core_payment_histories", ["owner_type"], :name => "index_payment_histories_on_owner_type"
  end

  def down
    drop_table :core_payment_histories
  end
end
