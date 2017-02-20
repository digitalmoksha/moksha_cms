# This migration comes from dm_core (originally 20160821150129)
class IndexForeignKeysInRoles < ActiveRecord::Migration
  def change
    add_index :roles, :resource_id
  end
end
