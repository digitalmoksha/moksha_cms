class IndexForeignKeysInCmsPosts < ActiveRecord::Migration[4.2]
  def change
    add_index :cms_posts, :account_id
    add_index :cms_posts, :cms_blog_id
  end
end
