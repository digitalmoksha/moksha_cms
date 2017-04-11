class AddObjectChangesColumnToVersions < ActiveRecord::Migration[4.2]
  def self.up
    add_column :versions, :object_changes, :text
    add_column :versions, :locale, :string
  end

  def self.down
    remove_column :versions, :object_changes
    remove_column :versions, :locale
  end
end
