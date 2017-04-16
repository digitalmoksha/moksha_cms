class IndexForeignKeysInFmsForums < ActiveRecord::Migration[4.2]
  def change
    add_index :fms_forums, :forum_category_id
    add_index :fms_forums, :forum_site_id
    add_index :fms_forums, :owner_id
  end
end
