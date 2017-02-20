# This migration comes from dm_core (originally 20160821150135)
class IndexForeignKeysInVersions < ActiveRecord::Migration
  def change
    add_index :versions, :item_id
  end
end
