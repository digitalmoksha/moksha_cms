class IndexForeignKeysInEmsWorkshops < ActiveRecord::Migration
  def change
    add_index :ems_workshops, :account_id
    add_index :ems_workshops, :country_id
  end
end
