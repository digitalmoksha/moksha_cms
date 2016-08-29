class IndexForeignKeysInRoles < ActiveRecord::Migration
  def change
    add_index :roles, :resource_id
  end
end
