class IndexForeignKeysInFmsForumSites < ActiveRecord::Migration
  def change
    add_index :fms_forum_sites, :account_id
  end
end
