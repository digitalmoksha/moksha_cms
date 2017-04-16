class AddCoreAddresses < ActiveRecord::Migration[4.2]
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
      t.timestamps null: true
    end
 
    add_index :core_addresses, [:addressable_type, :addressable_id], :unique => true
  end
end
