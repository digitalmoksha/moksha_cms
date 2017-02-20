# This migration comes from dm_core (originally 20160821150113)
class IndexForeignKeysInCoreAddresses < ActiveRecord::Migration
  def change
    add_index :core_addresses, :addressable_id
  end
end
