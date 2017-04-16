# encoding: UTF-8
#------------------------------------------------------------------------------
class AddGlobalizeCountries < ActiveRecord::Migration[4.2]
  def up
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

    add_index "globalize_countries", ["code"],    :name => "index_globalize_countries_on_code"
    add_index "globalize_countries", ["locale"],  :name => "index_globalize_countries_on_locale"

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
  end

  def down
    drop_table :globalize_countries
    drop_table :globalize_languages
  end
end
