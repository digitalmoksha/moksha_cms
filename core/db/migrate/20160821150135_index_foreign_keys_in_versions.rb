class IndexForeignKeysInVersions < ActiveRecord::Migration
  def change
    add_index :versions, :item_id
  end
end
