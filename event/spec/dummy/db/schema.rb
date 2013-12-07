# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131203214108) do

  create_table "core_accounts", :force => true do |t|
    t.string   "company_name"
    t.string   "contact_email"
    t.string   "domain"
    t.string   "account_prefix"
    t.integer  "default_site_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "core_activities", :force => true do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.string   "browser"
    t.string   "session_id"
    t.string   "ip_address"
    t.string   "controller"
    t.string   "action"
    t.string   "params"
    t.string   "slug"
    t.string   "lesson"
    t.datetime "created_at"
  end

  add_index "core_activities", ["account_id"], :name => "index_core_activities_on_account_id"
  add_index "core_activities", ["user_id"], :name => "index_core_activities_on_user_id"

  create_table "core_categories", :force => true do |t|
    t.string   "type"
    t.integer  "row_order"
    t.integer  "account_id"
    t.datetime "created_on"
    t.datetime "updated_on"
  end

  create_table "core_category_translations", :force => true do |t|
    t.integer  "core_category_id"
    t.string   "locale"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "core_category_translations", ["core_category_id"], :name => "index_category_translation"

  create_table "core_comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "body"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.string   "role",                           :default => "comments"
    t.integer  "account_id"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.string   "type"
    t.string   "ancestry"
    t.integer  "ancestry_depth",                 :default => 0
  end

  add_index "core_comments", ["commentable_id"], :name => "index_core_comments_on_commentable_id"
  add_index "core_comments", ["commentable_type"], :name => "index_core_comments_on_commentable_type"
  add_index "core_comments", ["user_id"], :name => "index_core_comments_on_user_id"

  create_table "core_payment_histories", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type",      :limit => 30
    t.string   "anchor_id",       :limit => 20
    t.string   "order_ref"
    t.string   "item_ref"
    t.string   "item_name"
    t.integer  "quantity"
    t.string   "cost"
    t.string   "discount"
    t.integer  "total_cents"
    t.string   "total_currency",  :limit => 3
    t.string   "payment_method"
    t.datetime "payment_date"
    t.string   "bill_to_name"
    t.text     "item_details"
    t.text     "order_details"
    t.string   "status"
    t.integer  "user_profile_id"
    t.datetime "created_on"
    t.integer  "account_id"
    t.text     "notify_data"
    t.string   "transaction_id"
  end

  add_index "core_payment_histories", ["anchor_id"], :name => "index_payment_histories_on_anchor_id"
  add_index "core_payment_histories", ["item_ref"], :name => "index_payment_histories_on_item_ref"
  add_index "core_payment_histories", ["order_ref"], :name => "index_payment_histories_on_order_ref"
  add_index "core_payment_histories", ["owner_id"], :name => "index_payment_histories_on_owner_id"
  add_index "core_payment_histories", ["owner_type"], :name => "index_payment_histories_on_owner_type"

  create_table "core_system_email_translations", :force => true do |t|
    t.integer  "core_system_email_id"
    t.string   "locale"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "core_system_emails", :force => true do |t|
    t.string   "email_type"
    t.integer  "emailable_id"
    t.string   "emailable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  create_table "ems_registrations", :force => true do |t|
    t.integer  "workshop_id"
    t.string   "receipt_code",             :limit => 20
    t.boolean  "receipt_requested"
    t.integer  "workshop_price_id"
    t.integer  "amount_paid_cents",                      :default => 0
    t.integer  "discount_value"
    t.boolean  "discount_use_percent"
    t.string   "payment_comment"
    t.datetime "checkin_at"
    t.string   "aasm_state",               :limit => 20
    t.datetime "process_changed_on"
    t.datetime "user_updated_at"
    t.datetime "archived_on"
    t.datetime "confirmed_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.integer  "lock_version",                           :default => 0
    t.string   "registered_locale",        :limit => 5
    t.integer  "user_profile_id"
    t.string   "amount_paid_currency"
    t.datetime "payment_reminder_sent_on"
  end

  add_index "ems_registrations", ["receipt_code"], :name => "receipt_code_key"

  create_table "ems_workshop_price_translations", :force => true do |t|
    t.integer  "ems_workshop_price_id"
    t.string   "locale"
    t.string   "price_description"
    t.text     "sub_description"
    t.text     "payment_details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ems_workshop_prices", :force => true do |t|
    t.integer  "workshop_id"
    t.integer  "price_cents"
    t.string   "price_currency",      :limit => 10
    t.integer  "alt1_price_cents"
    t.string   "alt1_price_currency", :limit => 10
    t.integer  "alt2_price_cents"
    t.string   "alt2_price_currency", :limit => 10
    t.boolean  "disabled",                          :default => false, :null => false
    t.date     "valid_until"
    t.date     "valid_starting_on"
    t.integer  "total_available"
    t.integer  "recurring_amount"
    t.integer  "recurring_period"
    t.integer  "recurring_number"
    t.integer  "row_order"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ems_workshop_translations", :force => true do |t|
    t.integer  "ems_workshop_id"
    t.string   "locale"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "sidebar"
  end

  create_table "ems_workshops", :force => true do |t|
    t.string   "slug"
    t.datetime "starting_on"
    t.datetime "ending_on"
    t.date     "deadline_on"
    t.integer  "registrations_count",               :default => 0
    t.integer  "country_id"
    t.string   "contact_email",       :limit => 60, :default => ""
    t.string   "contact_phone",       :limit => 20, :default => ""
    t.string   "info_url",                          :default => ""
    t.boolean  "require_review",                    :default => false
    t.boolean  "waitlisting",                       :default => false
    t.text     "closed_text"
    t.boolean  "published"
    t.datetime "archived_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.boolean  "require_account"
    t.boolean  "require_address"
    t.boolean  "require_photo"
    t.string   "base_currency",       :limit => 3
    t.string   "event_style",                       :default => "workshop"
    t.integer  "funding_goal_cents",                :default => 0
    t.boolean  "payments_enabled"
    t.boolean  "show_address"
  end

  add_index "ems_workshops", ["slug"], :name => "workshopname_key"

  create_table "globalize_countries", :force => true do |t|
    t.string "code",                   :limit => 2
    t.string "english_name"
    t.string "date_format"
    t.string "currency_format"
    t.string "currency_code",          :limit => 3
    t.string "thousands_sep",          :limit => 2
    t.string "decimal_sep",            :limit => 2
    t.string "currency_decimal_sep",   :limit => 2
    t.string "number_grouping_scheme"
    t.string "continent"
    t.string "locale"
  end

  add_index "globalize_countries", ["code"], :name => "index_globalize_countries_on_code"
  add_index "globalize_countries", ["locale"], :name => "index_globalize_countries_on_locale"

  create_table "globalize_languages", :force => true do |t|
    t.string  "iso_639_1",             :limit => 2
    t.string  "iso_639_2",             :limit => 3
    t.string  "iso_639_3",             :limit => 3
    t.string  "rfc_3066"
    t.string  "english_name"
    t.string  "english_name_locale"
    t.string  "english_name_modifier"
    t.string  "native_name"
    t.string  "native_name_locale"
    t.string  "native_name_modifier"
    t.boolean "macro_language"
    t.string  "direction"
    t.string  "pluralization"
    t.string  "scope",                 :limit => 1
  end

  add_index "globalize_languages", ["iso_639_1"], :name => "index_globalize_languages_on_iso_639_1"
  add_index "globalize_languages", ["iso_639_2"], :name => "index_globalize_languages_on_iso_639_2"
  add_index "globalize_languages", ["iso_639_3"], :name => "index_globalize_languages_on_iso_639_3"
  add_index "globalize_languages", ["rfc_3066"], :name => "index_globalize_languages_on_rfc_3066"

  create_table "preferences", :force => true do |t|
    t.string   "name",       :null => false
    t.integer  "owner_id",   :null => false
    t.string   "owner_type", :null => false
    t.integer  "group_id"
    t.string   "group_type"
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "preferences", ["owner_id", "owner_type", "name", "group_id", "group_type"], :name => "index_preferences_on_owner_and_name_and_preference", :unique => true

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "account_id"
  end

  add_index "roles", ["account_id"], :name => "index_roles_on_account_id"
  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "sub_subscription_plans", :force => true do |t|
    t.string   "name"
    t.string   "vendor_plan_id"
    t.integer  "amount_cents"
    t.string   "currency",          :limit => 3
    t.string   "interval"
    t.integer  "trial_period_days"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.boolean  "deleted",                        :default => false
    t.integer  "account_id"
  end

  create_table "sub_user_subscriptions", :force => true do |t|
    t.integer  "subscription_plan_id"
    t.integer  "user_id"
    t.integer  "account_id"
    t.string   "last_4_digits"
    t.string   "subscription_token"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "user_profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "public_name",                   :limit => 50, :default => ""
    t.string   "first_name",                    :limit => 50, :default => ""
    t.string   "last_name",                     :limit => 50, :default => ""
    t.string   "address",                       :limit => 70, :default => ""
    t.string   "address2",                      :limit => 70, :default => ""
    t.string   "city",                          :limit => 30, :default => ""
    t.string   "state",                         :limit => 30, :default => ""
    t.string   "zipcode",                       :limit => 10, :default => ""
    t.integer  "country_id",                                  :default => 0
    t.string   "phone",                         :limit => 20, :default => ""
    t.string   "cell",                          :limit => 20, :default => ""
    t.string   "fax",                           :limit => 20, :default => ""
    t.string   "workphone",                     :limit => 20, :default => ""
    t.string   "website",                       :limit => 50, :default => ""
    t.string   "gender",                        :limit => 1,  :default => ""
    t.integer  "status",                                      :default => 0
    t.integer  "lock_version",                                :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.string   "email"
    t.string   "public_avatar"
    t.integer  "public_avatar_file_size"
    t.string   "public_avatar_content_type"
    t.string   "private_avatar"
    t.integer  "private_avatar_file_size"
    t.string   "private_avatar_content_type"
    t.boolean  "use_private_avatar_for_public",               :default => false
  end

  create_table "user_site_profiles", :force => true do |t|
    t.integer  "user_id"
    t.datetime "last_access_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "account_id"
  end

  add_index "users", ["account_id"], :name => "index_users_on_account_id"
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :null => false
    t.integer  "item_id",        :null => false
    t.string   "event",          :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.string   "locale"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
