class CreateEvents < ActiveRecord::Migration
  def up
    create_table :ems_workshop_translations, :force => true do |t|
      t.integer     :ems_workshop_id
      t.string      :locale
      t.string      :title
      t.text        :description
      t.text        :payment_instructions
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
      t.datetime    :archived_on
      t.datetime    :created_at
      t.datetime    :updated_at
      t.integer     :account_id
      # t.string      :template,                        :limit => 50
      # t.text        :closed_text
      # t.boolean     :is_closed
      # t.string      :heardabout_list
      # t.boolean     :heardabout_required,                            :default => false
      # t.boolean     :show_personal,                                  :default => false
      # t.boolean     :show_medical,                                   :default => false
      # t.boolean     :show_spiritual,                                 :default => false
      # t.boolean     :show_arrival_departure,                         :default => false
      # t.boolean     :require_account,                                :default => true
      # t.boolean     :show_photo,                                     :default => false
      # t.boolean     :show_programdate,                               :default => true
      # t.text     "pending_email"
      # t.text     "accepted_email"
      # t.text     "rejected_email"
      # t.text     "paid_email"
      # t.string   "pending_subject"
      # t.string   "accepted_subject"
      # t.string   "rejected_subject"
      # t.string   "paid_subject"
      # t.text     "waitlisted_email"
      # t.string   "waitlisted_subject"
      # t.boolean  "require_address",                                :default => true
      # t.boolean  "shoppingcart_immediate_checkout"
      # t.string   "invitation_code"
      # t.text     "information_text"
      # t.boolean  "track_payments",                                 :default => true
      # t.text     "event_information_text"
      # t.boolean  "ashram_program",                                 :default => false
      # t.text     "note"
    end
    
    add_index :ems_workshops, ["slug"], :name => "workshopname_key"
    
    create_table :ems_registrations, :force => true do |t|
      t.integer     :workshop_id
      t.integer     :user_id
      t.string      :receipt_code,         :limit => 20
      t.integer     :workshop_price_id
      t.string      :aasm_state,           :limit => 20
      t.datetime    :process_changed_on
      t.datetime    :user_updated_at
      t.datetime    :archived_on
      t.datetime    :confirmed_on
      t.datetime    :created_at
      t.datetime    :updated_at
      t.integer     :account_id
      t.integer     :lock_version,                       :default => 0
      # t.string   :firstname,            :limit => 50
      # t.string   :lastname,             :limit => 50
      # t.string   :email,                :limit => 60
      # t.string   :address,              :limit => 70
      # t.string   :address2,             :limit => 70
      # t.string   :city,                 :limit => 20
      # t.string   :state,                :limit => 30, :default => "",    :null => false
      # t.string   :zipcode,              :limit => 10
      # t.integer  :country_id
      # t.string   :phone,                :limit => 20
      # t.string   :fax,                  :limit => 20
      # t.date     :dob
      # t.string   :gender,               :limit => 1,  :default => "",    :null => false
      # t.boolean  :married,                            :default => false
      # t.string   :cell,                 :limit => 20
      # t.string   :children
      # t.string   :occupation_skills
      # t.string   :roomate_pref
      # t.boolean  :speak_english,                      :default => true
      # t.string   :health_conditions
      # t.string   :medication_allergies
      # t.string   :special_requirements
      # t.string   :psych_care
      # t.string   :item_code
      # t.integer  :amount,                             :default => 0
      # t.string   :heardabout,           :limit => 50
      # t.datetime :checkin_at
      # t.datetime :payment_verified_at
      # t.string   :token,                :limit => 40
      # t.integer  :room_id
      # t.boolean  :receipt_requested
      # t.integer  :discount_value
      # t.boolean  :discount_use_percent
      # t.string   :payment_comment
      # t.integer  :arrival_vehicle_id
      # t.integer  :departure_vehicle_id
      # t.datetime :arrival_at
      # t.datetime :departure_at
    end
    
    add_index :ems_registrations, ["receipt_code"], :name => "receipt_code_key"
    
    create_table :ems_workshop_prices, :force => true do |t|
      t.integer     :workshop_id
      t.string      :price_desc,                          :default => "",    :null => false
      t.string      :sub_description
      t.integer     :price_cents
      t.string      :price_currency,          :limit => 10
      t.integer     :alt1_price_cents
      t.string      :alt1_price_currency,     :limit => 10
      t.integer     :alt2_price_cents
      t.string      :alt2_price_currency,     :limit => 10
      t.boolean     :disable,                               :default => false, :null => false
      t.date        :valid_until
      t.date        :valid_starting_on
      t.integer     :total_available
      t.integer     :row_order
      t.integer     :account_id
      # t.integer     :recurring_amount
      # t.integer     :recurring_period
      # t.integer     :recurring_number
      # t.string      "shoppingcart_code"
      # t.string      "payment_type",      :limit => 20
    end

  end

  def down
    drop_table    :ems_workshops
    drop_table    :ems_workshop_translations
    drop_table    :ems_registrations
    drop_table    :ems_workshop_prices
  end
end
