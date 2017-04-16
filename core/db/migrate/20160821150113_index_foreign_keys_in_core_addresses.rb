class IndexForeignKeysInCoreAddresses < ActiveRecord::Migration[4.2]
  def change
    add_index :core_addresses, :addressable_id
  end
end
