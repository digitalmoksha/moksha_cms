# This migration comes from dm_core (originally 20160128094739)
# Migration for upgrading PaperTrail from V3 to V4
#------------------------------------------------------------------------------
class UpdatePapertrailV4 < ActiveRecord::Migration
  # The largest text column available in all supported RDBMS is
  # 1024^3 - 1 bytes, roughly one gibibyte.  We specify a size
  # so that MySQL will use `longtext` instead of `text`.  Otherwise,
  # when serializing very large objects, `text` might not be big enough.
  TEXT_BYTES = 1_073_741_823

  def up
    change_column :versions, :created_at,     :datetime, precision: 6
    change_column :versions, :object,         :text, limit: TEXT_BYTES
    change_column :versions, :object_changes, :text, limit: TEXT_BYTES
    add_column    :versions, :transaction_id, :integer
    add_index     :versions, [:transaction_id]

    create_table :version_associations do |t|
      t.integer  :version_id
      t.string   :foreign_key_name, :null => false
      t.integer  :foreign_key_id
    end
    add_index :version_associations, [:version_id]
    add_index :version_associations,
      [:foreign_key_name, :foreign_key_id],
      :name => 'index_version_associations_on_foreign_key'
  end

  def down
    change_column :versions, :created_at,     :datetime
    change_column :versions, :object,         :mediumtext
    change_column :versions, :object_changes, :mediumtext
    remove_index  :versions, [:transaction_id]
    remove_column :versions, :transaction_id

    remove_index :version_associations, [:version_id]
    remove_index :version_associations,
      :name => 'index_version_associations_on_foreign_key'
    drop_table :version_associations
  end
end
