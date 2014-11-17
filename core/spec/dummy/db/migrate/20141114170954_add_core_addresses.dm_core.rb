# This migration comes from dm_core (originally 20140210195143)
class AddCoreAddresses < ActiveRecord::Migration
  def change
    create_table :core_addresses do |t|
      t.string    :line1
      t.string    :line2
      t.string    :city
      t.string    :state
      t.string    :zip
      t.string    :country_code,    limit: 2
      t.integer   :addressable_id
      t.string    :addressable_type
      t.timestamps
    end
 
    add_index :core_addresses, [:addressable_type, :addressable_id], :unique => true
  end
end
