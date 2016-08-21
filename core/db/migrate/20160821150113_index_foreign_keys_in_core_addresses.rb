class IndexForeignKeysInCoreAddresses < ActiveRecord::Migration
  def change
    add_index :core_addresses, :addressable_id
  end
end
