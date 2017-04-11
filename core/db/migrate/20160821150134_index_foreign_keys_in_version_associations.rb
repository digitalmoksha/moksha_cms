class IndexForeignKeysInVersionAssociations < ActiveRecord::Migration[4.2]
  def change
    add_index :version_associations, :foreign_key_id
  end
end
