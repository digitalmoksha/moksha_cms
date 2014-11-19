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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141119103753) do

  create_table "cms_blog_translations", force: true do |t|
    t.integer  "cms_blog_id"
    t.string   "locale"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cms_blog_translations", ["cms_blog_id"], name: "index_cms_blog_translations_on_cms_blog_id"

  create_table "cms_blogs", force: true do |t|
    t.string   "slug"
    t.boolean  "published",             default: false
    t.boolean  "is_public",             default: false
    t.boolean  "requires_login",        default: false
    t.integer  "row_order"
    t.datetime "updated_on"
    t.datetime "created_on"
    t.integer  "account_id"
    t.integer  "lock_version",          default: 0,     null: false
    t.boolean  "comments_allowed"
    t.string   "header_image"
    t.boolean  "requires_subscription", default: false
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "image_email_header"
  end

  add_index "cms_blogs", ["published"], name: "cms_blogs_published_index"
  add_index "cms_blogs", ["slug"], name: "blogname_key"

  create_table "cms_contentitem_translations", force: true do |t|
    t.integer  "cms_contentitem_id"
    t.string   "locale"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cms_contentitem_translations", ["cms_contentitem_id"], name: "index_072c3a76f87c96e2f91149eccd2a283dca2b613f"

  create_table "cms_contentitems", force: true do |t|
    t.integer  "cms_page_id"
    t.string   "itemtype",     limit: 30, default: "textile"
    t.string   "container",    limit: 30
    t.integer  "row_order",               default: 0
    t.boolean  "enable_cache",            default: true,      null: false
    t.datetime "created_on"
    t.datetime "updated_on"
    t.integer  "lock_version",            default: 0
    t.integer  "account_id"
  end

  add_index "cms_contentitems", ["account_id"], name: "index_cms_contentitems_on_account_id"
  add_index "cms_contentitems", ["cms_page_id"], name: "cms_contentitems_cms_page_id_index"

  create_table "cms_media_file_translations", force: true do |t|
    t.integer  "cms_media_file_id"
    t.string   "locale"
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cms_media_file_translations", ["cms_media_file_id"], name: "index_cms_media_file_translations_on_cms_media_file_id"

  create_table "cms_media_files", force: true do |t|
    t.string   "media"
    t.integer  "media_file_size"
    t.string   "media_content_type"
    t.string   "folder"
    t.boolean  "generate_retina"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  add_index "cms_media_files", ["media", "folder", "account_id"], name: "index_media_folder_account_id", unique: true

  create_table "cms_page_translations", force: true do |t|
    t.integer  "cms_page_id"
    t.string   "locale"
    t.string   "title"
    t.string   "menutitle"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "summary"
  end

  add_index "cms_page_translations", ["cms_page_id"], name: "index_cms_page_translations_on_cms_page_id"

  create_table "cms_pages", force: true do |t|
    t.string   "slug",                  limit: 50, default: "",        null: false
    t.string   "pagetype",              limit: 20, default: "content", null: false
    t.boolean  "published",                        default: false,     null: false
    t.string   "template",              limit: 50, default: "",        null: false
    t.string   "link",                             default: "",        null: false
    t.string   "menuimage"
    t.boolean  "requires_login",                   default: false
    t.string   "ancestry"
    t.integer  "ancestry_depth",                   default: 0
    t.datetime "updated_on"
    t.datetime "created_on"
    t.integer  "lock_version",                     default: 0,         null: false
    t.integer  "account_id"
    t.boolean  "requires_subscription",            default: false
    t.boolean  "is_public",                        default: true
    t.integer  "row_order"
    t.string   "featured_image"
    t.string   "header_image"
  end

  add_index "cms_pages", ["account_id"], name: "index_cms_pages_on_account_id"
  add_index "cms_pages", ["ancestry"], name: "index_cms_pages_on_ancestry"
  add_index "cms_pages", ["ancestry_depth"], name: "index_cms_pages_on_ancestry_depth"
  add_index "cms_pages", ["published"], name: "cms_pages_published_index"
  add_index "cms_pages", ["slug"], name: "pagename_key"

  create_table "cms_post_translations", force: true do |t|
    t.integer  "cms_post_id"
    t.string   "locale"
    t.string   "title"
    t.text     "content"
    t.text     "summary"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cms_post_translations", ["cms_post_id"], name: "index_cms_post_translations_on_cms_post_id"

  create_table "cms_posts", force: true do |t|
    t.string   "slug"
    t.integer  "cms_blog_id"
    t.string   "featured_image"
    t.datetime "published_on"
    t.datetime "updated_on"
    t.datetime "created_on"
    t.integer  "account_id"
    t.integer  "lock_version",         default: 0, null: false
    t.datetime "notification_sent_on"
    t.integer  "comments_count",       default: 0
    t.boolean  "comments_allowed"
  end

  add_index "cms_posts", ["published_on"], name: "cms_posts_published_index"
  add_index "cms_posts", ["slug"], name: "postname_key"

  create_table "cms_snippet_translations", force: true do |t|
    t.integer  "cms_snippet_id"
    t.string   "locale"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cms_snippet_translations", ["cms_snippet_id"], name: "index_cms_snippet_translations_on_cms_snippet_id"

  create_table "cms_snippets", force: true do |t|
    t.string   "itemtype",     limit: 30, default: "markdown"
    t.string   "slug"
    t.string   "description"
    t.boolean  "enable_cache",            default: true,       null: false
    t.boolean  "published",               default: true,       null: false
    t.datetime "created_on"
    t.datetime "updated_on"
    t.integer  "lock_version",            default: 0
    t.integer  "account_id"
  end

  add_index "cms_snippets", ["account_id"], name: "index_cms_snippets_on_account_id"
  add_index "cms_snippets", ["slug"], name: "index_cms_snippets_on_slug"

  create_table "core_accounts", force: true do |t|
    t.string   "company_name"
    t.string   "contact_email"
    t.string   "domain"
    t.string   "account_prefix"
    t.integer  "default_site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "next_invoice_num", default: 1000
  end

  create_table "core_activities", force: true do |t|
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

  add_index "core_activities", ["account_id"], name: "index_core_activities_on_account_id"
  add_index "core_activities", ["user_id"], name: "index_core_activities_on_user_id"

  create_table "core_addresses", force: true do |t|
    t.string   "line1"
    t.string   "line2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country_code",     limit: 2
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "core_addresses", ["addressable_type", "addressable_id"], name: "index_core_addresses_on_addressable_type_and_addressable_id", unique: true

  create_table "core_categories", force: true do |t|
    t.string   "type"
    t.integer  "row_order"
    t.integer  "account_id"
    t.datetime "created_on"
    t.datetime "updated_on"
  end

  create_table "core_category_translations", force: true do |t|
    t.integer  "core_category_id"
    t.string   "locale"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "core_category_translations", ["core_category_id"], name: "index_category_translation"

  create_table "core_comments", force: true do |t|
    t.string   "title",            limit: 50, default: ""
    t.text     "body"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.string   "role",                        default: "comments"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "ancestry"
    t.integer  "ancestry_depth",              default: 0
  end

  add_index "core_comments", ["commentable_id"], name: "index_core_comments_on_commentable_id"
  add_index "core_comments", ["commentable_type"], name: "index_core_comments_on_commentable_type"
  add_index "core_comments", ["user_id"], name: "index_core_comments_on_user_id"

  create_table "core_custom_field_def_translations", force: true do |t|
    t.integer  "core_custom_field_def_id"
    t.string   "locale"
    t.string   "label"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "core_custom_field_def_translations", ["core_custom_field_def_id"], name: "core_custom_field_def_translations_index"

  create_table "core_custom_field_defs", force: true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "name"
    t.string   "field_type"
    t.integer  "row_order"
    t.boolean  "required",                default: false
    t.string   "properties", limit: 2048
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  add_index "core_custom_field_defs", ["account_id"], name: "index_core_custom_field_defs_on_account_id"
  add_index "core_custom_field_defs", ["owner_id", "owner_type"], name: "index_core_custom_field_defs_on_owner_id_and_owner_type"

  create_table "core_custom_fields", force: true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "custom_field_def_id"
    t.string   "field_data",          limit: 4096
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  add_index "core_custom_fields", ["account_id"], name: "index_core_custom_fields_on_account_id"
  add_index "core_custom_fields", ["owner_id", "owner_type"], name: "index_core_custom_fields_on_owner_id_and_owner_type"

  create_table "core_payment_histories", force: true do |t|
    t.integer  "owner_id"
    t.string   "owner_type",      limit: 30
    t.string   "anchor_id",       limit: 20
    t.string   "order_ref"
    t.string   "item_ref"
    t.string   "item_name"
    t.integer  "quantity"
    t.string   "cost"
    t.string   "discount"
    t.integer  "total_cents"
    t.string   "total_currency",  limit: 3
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

  add_index "core_payment_histories", ["anchor_id"], name: "index_payment_histories_on_anchor_id"
  add_index "core_payment_histories", ["item_ref"], name: "index_payment_histories_on_item_ref"
  add_index "core_payment_histories", ["order_ref"], name: "index_payment_histories_on_order_ref"
  add_index "core_payment_histories", ["owner_id"], name: "index_payment_histories_on_owner_id"
  add_index "core_payment_histories", ["owner_type"], name: "index_payment_histories_on_owner_type"

  create_table "core_system_email_translations", force: true do |t|
    t.integer  "core_system_email_id"
    t.string   "locale"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "core_system_emails", force: true do |t|
    t.string   "email_type"
    t.integer  "emailable_id"
    t.string   "emailable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  create_table "ems_registrations", force: true do |t|
    t.integer  "workshop_id"
    t.string   "receipt_code",             limit: 20
    t.boolean  "receipt_requested"
    t.integer  "workshop_price_id"
    t.integer  "amount_paid_cents",                   default: 0
    t.integer  "discount_value"
    t.boolean  "discount_use_percent"
    t.datetime "checkin_at"
    t.string   "aasm_state",               limit: 20
    t.datetime "process_changed_on"
    t.datetime "user_updated_at"
    t.datetime "archived_on"
    t.datetime "confirmed_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.integer  "lock_version",                        default: 0
    t.string   "registered_locale",        limit: 5
    t.integer  "user_profile_id"
    t.string   "amount_paid_currency"
    t.datetime "payment_reminder_sent_on"
    t.string   "uuid",                     limit: 36
    t.integer  "comments_count"
    t.integer  "payment_comment_id"
  end

  add_index "ems_registrations", ["receipt_code"], name: "receipt_code_key"
  add_index "ems_registrations", ["uuid"], name: "index_ems_registrations_on_uuid"

  create_table "ems_workshop_price_translations", force: true do |t|
    t.integer  "ems_workshop_price_id"
    t.string   "locale"
    t.string   "price_description"
    t.text     "sub_description"
    t.text     "payment_details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ems_workshop_prices", force: true do |t|
    t.integer  "workshop_id"
    t.integer  "price_cents"
    t.string   "price_currency",      limit: 10
    t.integer  "alt1_price_cents"
    t.string   "alt1_price_currency", limit: 10
    t.integer  "alt2_price_cents"
    t.string   "alt2_price_currency", limit: 10
    t.boolean  "disabled",                       default: false, null: false
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

  create_table "ems_workshop_translations", force: true do |t|
    t.integer  "ems_workshop_id"
    t.string   "locale"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "sidebar"
    t.text     "summary"
  end

  create_table "ems_workshops", force: true do |t|
    t.string   "slug"
    t.datetime "starting_on"
    t.datetime "ending_on"
    t.date     "deadline_on"
    t.integer  "registrations_count",            default: 0
    t.integer  "country_id"
    t.string   "contact_email",       limit: 60, default: ""
    t.string   "contact_phone",       limit: 20, default: ""
    t.string   "info_url",                       default: ""
    t.boolean  "require_review",                 default: false
    t.boolean  "waitlisting",                    default: false
    t.text     "closed_text"
    t.boolean  "published"
    t.datetime "archived_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.boolean  "require_account"
    t.boolean  "require_address"
    t.boolean  "require_photo"
    t.string   "base_currency",       limit: 3
    t.string   "event_style",                    default: "workshop"
    t.integer  "funding_goal_cents",             default: 0
    t.boolean  "payments_enabled"
    t.boolean  "show_address"
    t.string   "image"
  end

  add_index "ems_workshops", ["slug"], name: "workshopname_key"

  create_table "follows", force: true do |t|
    t.integer  "followable_id",                   null: false
    t.string   "followable_type",                 null: false
    t.integer  "follower_id",                     null: false
    t.string   "follower_type",                   null: false
    t.boolean  "blocked",         default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["followable_id", "followable_type"], name: "fk_followables"
  add_index "follows", ["follower_id", "follower_type"], name: "fk_follows"

  create_table "globalize_countries", force: true do |t|
    t.string "code",                   limit: 2
    t.string "english_name"
    t.string "date_format"
    t.string "currency_format"
    t.string "currency_code",          limit: 3
    t.string "thousands_sep",          limit: 2
    t.string "decimal_sep",            limit: 2
    t.string "currency_decimal_sep",   limit: 2
    t.string "number_grouping_scheme"
    t.string "continent"
    t.string "locale"
  end

  add_index "globalize_countries", ["code"], name: "index_globalize_countries_on_code"
  add_index "globalize_countries", ["locale"], name: "index_globalize_countries_on_locale"

  create_table "globalize_languages", force: true do |t|
    t.string  "iso_639_1",             limit: 2
    t.string  "iso_639_2",             limit: 3
    t.string  "iso_639_3",             limit: 3
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
    t.string  "scope",                 limit: 1
  end

  add_index "globalize_languages", ["iso_639_1"], name: "index_globalize_languages_on_iso_639_1"
  add_index "globalize_languages", ["iso_639_2"], name: "index_globalize_languages_on_iso_639_2"
  add_index "globalize_languages", ["iso_639_3"], name: "index_globalize_languages_on_iso_639_3"
  add_index "globalize_languages", ["rfc_3066"], name: "index_globalize_languages_on_rfc_3066"

  create_table "preferences", force: true do |t|
    t.string   "name",       null: false
    t.integer  "owner_id",   null: false
    t.string   "owner_type", null: false
    t.integer  "group_id"
    t.string   "group_type"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preferences", ["owner_id", "owner_type", "name", "group_id", "group_type"], name: "index_preferences_on_owner_and_name_and_preference", unique: true

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  add_index "roles", ["account_id"], name: "index_roles_on_account_id"
  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], name: "index_roles_on_name"

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true

  create_table "user_profiles", force: true do |t|
    t.integer  "user_id"
    t.string   "public_name",                   limit: 50, default: ""
    t.string   "first_name",                    limit: 50, default: ""
    t.string   "last_name",                     limit: 50, default: ""
    t.string   "address",                       limit: 70, default: ""
    t.string   "address2",                      limit: 70, default: ""
    t.string   "city",                          limit: 30, default: ""
    t.string   "state",                         limit: 30, default: ""
    t.string   "zipcode",                       limit: 10, default: ""
    t.integer  "country_id",                               default: 0
    t.string   "phone",                         limit: 20, default: ""
    t.string   "cell",                          limit: 20, default: ""
    t.string   "fax",                           limit: 20, default: ""
    t.string   "workphone",                     limit: 20, default: ""
    t.string   "website",                       limit: 50, default: ""
    t.string   "gender",                        limit: 1,  default: ""
    t.integer  "status",                                   default: 0
    t.integer  "lock_version",                             default: 0
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
    t.boolean  "use_private_avatar_for_public",            default: false
  end

  create_table "user_site_profiles", force: true do |t|
    t.integer  "user_id"
    t.datetime "last_access_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.string   "uuid",           limit: 40
  end

  add_index "user_site_profiles", ["uuid"], name: "index_user_site_profiles_on_uuid"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  add_index "users", ["account_id"], name: "index_users_on_account_id"
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"

  create_table "versions", force: true do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.string   "locale"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

  create_table "votes", force: true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope"
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope"

end
