class ChangeWriteOff < ActiveRecord::Migration[5.0]
  def up
    add_column :ems_registrations, :writtenoff_on, :datetime
    Registration.unscoped.where(writeoff: true).each do |r|
      Account.current = Account.find(r.account_id)
      r.update_attribute(:writtenoff_on, Time.now) if r.writeoff
    end
    remove_column :ems_registrations, :writeoff
  end

  def down
    add_column :ems_registrations, :writeoff, :boolean, default: false
    Registration.unscoped.each do |r|
      Account.current = Account.find(r.account_id)
      r.update_attribute(:writeoff, true) if r.writtenoff_on
    end
    remove_column :ems_registrations, :writtenoff_on
  end
end
