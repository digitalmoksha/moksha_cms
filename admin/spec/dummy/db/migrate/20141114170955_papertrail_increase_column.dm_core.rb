# This migration comes from dm_core (originally 20140411190454)
class PapertrailIncreaseColumn < ActiveRecord::Migration
  def up
    change_column :versions, :object_changes, :mediumtext
  end
  def down
    change_column :versions, :object_changes, :text
  end
end
