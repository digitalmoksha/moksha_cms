class AddLocaleToRegistration < ActiveRecord::Migration[4.2]
  def change
    add_column    :ems_registrations,   :registered_locale, :string, :limit => 5
  end
end
