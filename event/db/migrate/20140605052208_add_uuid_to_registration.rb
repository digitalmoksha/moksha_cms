class AddUuidToRegistration < ActiveRecord::Migration
  def up
    add_column  :ems_registrations,   :uuid, :string,  limit: 36
    add_index   :ems_registrations,   :uuid
    Registration.unscoped.each {|r| r.update_attribute(:uuid, SecureRandom.uuid)}
  end
  def down
    remove_column  :ems_registrations,   :uuid
  end
end
