class IndexForeignKeysInUsersRoles < ActiveRecord::Migration[4.2]
  def change
    add_index :users_roles, :role_id
  end
end
