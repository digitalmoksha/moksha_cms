class IndexForeignKeysInCmsBlogs < ActiveRecord::Migration
  def change
    add_index :cms_blogs, :account_id
    add_index :cms_blogs, :owner_id
  end
end
