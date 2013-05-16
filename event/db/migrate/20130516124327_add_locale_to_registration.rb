class AddLocaleToRegistration < ActiveRecord::Migration
  def change
    add_column    :ems_registrations,   :registered_locale, :string, :limit => 5
  end
end
