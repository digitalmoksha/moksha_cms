class AddWriteOff < ActiveRecord::Migration[5.0]
  def change
    add_column :ems_registrations, :writeoff, :boolean, default: false
  end
end
