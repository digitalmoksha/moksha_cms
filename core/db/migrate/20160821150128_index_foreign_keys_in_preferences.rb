class IndexForeignKeysInPreferences < ActiveRecord::Migration
  def change
    add_index :preferences, :group_id
  end
end
