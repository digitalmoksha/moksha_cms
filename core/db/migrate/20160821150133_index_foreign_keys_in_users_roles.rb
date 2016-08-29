class IndexForeignKeysInUsersRoles < ActiveRecord::Migration
  def change
    add_index :users_roles, :role_id
  end
end
