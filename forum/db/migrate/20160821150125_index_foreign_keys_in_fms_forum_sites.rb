class IndexForeignKeysInFmsForumSites < ActiveRecord::Migration[4.2]
  def change
    add_index :fms_forum_sites, :account_id
  end
end
