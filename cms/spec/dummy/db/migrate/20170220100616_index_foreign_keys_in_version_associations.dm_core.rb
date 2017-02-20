# This migration comes from dm_core (originally 20160821150134)
class IndexForeignKeysInVersionAssociations < ActiveRecord::Migration
  def change
    add_index :version_associations, :foreign_key_id
  end
end
