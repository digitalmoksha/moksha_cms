# This migration comes from dm_core (originally 20121105205634)
class AddLastAccess < ActiveRecord::Migration
  def up
    add_column :users, :last_access_at,           :datetime
  end

  def down
    remove_column :users, :last_access_at
  end
end
