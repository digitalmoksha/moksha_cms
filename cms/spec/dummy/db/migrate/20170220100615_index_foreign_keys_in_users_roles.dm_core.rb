# This migration comes from dm_core (originally 20160821150133)
class IndexForeignKeysInUsersRoles < ActiveRecord::Migration
  def change
    add_index :users_roles, :role_id
  end
end
