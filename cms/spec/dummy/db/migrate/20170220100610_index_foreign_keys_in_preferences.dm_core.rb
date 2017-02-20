# This migration comes from dm_core (originally 20160821150128)
class IndexForeignKeysInPreferences < ActiveRecord::Migration
  def change
    add_index :preferences, :group_id
  end
end
