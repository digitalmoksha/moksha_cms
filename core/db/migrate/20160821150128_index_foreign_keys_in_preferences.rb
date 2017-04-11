class IndexForeignKeysInPreferences < ActiveRecord::Migration[4.2]
  def change
    add_index :preferences, :group_id
  end
end
