class IndexForeignKeysInRoles < ActiveRecord::Migration[4.2]
  def change
    add_index :roles, :resource_id
  end
end
