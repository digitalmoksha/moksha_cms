class CreateEvents < ActiveRecord::Migration
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
      t.datetime    :starting_on
      t.datetime    :ending_on
      t.date        :deadline_on
      t.integer     :registrations_count,                             :default => 0
      t.integer     :country_id
      t.string      :contact_email,                   :limit => 60,  :default => ""
      t.string      :contact_phone,                   :limit => 20,  :default => ""
      t.string      :info_url,                                       :default => ""
      t.string      :heardabout_list
      t.boolean     :heardabout_required,                            :default => false
      t.string      :template,                        :limit => 50
      t.boolean     :requires_review,                                :default => false
      t.boolean     :is_waitlisted,                                  :default => false
      t.boolean     :show_personal,                                  :default => false
      t.boolean     :show_medical,                                   :default => false
      t.boolean     :show_spiritual,                                 :default => false
      t.boolean     :show_arrival_departure,                         :default => false
      t.boolean     :require_account,                                :default => true
      t.boolean     :show_photo,                                     :default => false
      t.boolean     :show_programdate,                               :default => true
      t.datetime    :archived_on
      t.text        :closed_text
      t.boolean     :is_closed
      t.datetime    :created_at
      t.datetime    :updated_at
      t.integer     :account_id
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
  end

  def down
    drop_table    :ems_workshops
    drop_table    :ems_workshop_translations
  end
end
