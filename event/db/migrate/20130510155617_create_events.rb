class CreateEvents < ActiveRecord::Migration[4.2]
  def up
    create_table :ems_workshop_translations, :force => true do |t|
      t.integer     :ems_workshop_id
      t.string      :locale
      t.string      :title
      t.text        :description
      t.datetime    :created_at
      t.datetime    :updated_at
    end

    create_table :ems_workshops, :force => true do |t|
      t.string      :slug
      t.datetime    :starting_on
      t.datetime    :ending_on
      t.date        :deadline_on
      t.integer     :registrations_count,                             :default => 0
      t.integer     :country_id
      t.string      :contact_email,                   :limit => 60,  :default => ""
      t.string      :contact_phone,                   :limit => 20,  :default => ""
      t.string      :info_url,                                       :default => ""
      t.boolean     :require_review,                                 :default => false
      t.boolean     :waitlisting,                                    :default => false
      t.text        :closed_text
      t.boolean     :is_closed
      t.datetime    :archived_on
      t.datetime    :created_at
      t.datetime    :updated_at
      t.integer     :account_id
    end
    
    add_index :ems_workshops, ["slug"], :name => "workshopname_key"
    
    create_table :ems_registrations, :force => true do |t|
      t.integer     :workshop_id
      t.integer     :user_id
      t.string      :receipt_code,         :limit => 20
      t.boolean     :receipt_requested
      t.integer     :workshop_price_id
      t.integer     :amount,                             :default => 0
      t.integer     :discount_value
      t.boolean     :discount_use_percent
      t.string      :payment_comment
      t.datetime    :checkin_at
      t.string      :aasm_state,           :limit => 20
      t.datetime    :process_changed_on
      t.datetime    :user_updated_at
      t.datetime    :archived_on
      t.datetime    :confirmed_on
      t.datetime    :created_at
      t.datetime    :updated_at
      t.integer     :account_id
      t.integer     :lock_version,                       :default => 0
    end
    
    add_index :ems_registrations, ["receipt_code"], :name => "receipt_code_key"
    
    create_table :ems_workshop_price_translations, :force => true do |t|
      t.integer     :ems_workshop_price_id
      t.string      :locale
      t.string      :price_description
      t.text        :sub_description
      t.text        :payment_details
      t.datetime    :created_at
      t.datetime    :updated_at
    end

    create_table :ems_workshop_prices, :force => true do |t|
      t.integer     :workshop_id
      t.integer     :price_cents
      t.string      :price_currency,          :limit => 10
      t.integer     :alt1_price_cents
      t.string      :alt1_price_currency,     :limit => 10
      t.integer     :alt2_price_cents
      t.string      :alt2_price_currency,     :limit => 10
      t.boolean     :disabled,                               :default => false, :null => false
      t.date        :valid_until
      t.date        :valid_starting_on
      t.integer     :total_available
      t.integer     :recurring_amount
      t.integer     :recurring_period
      t.integer     :recurring_number
      t.integer     :row_order
      t.integer     :account_id
      t.datetime    :created_at
      t.datetime    :updated_at
    end

  end

  def down
    drop_table    :ems_workshops
    drop_table    :ems_workshop_translations
    drop_table    :ems_registrations
    drop_table    :ems_workshop_prices
    drop_table    :ems_workshop_price_translations
  end
end
