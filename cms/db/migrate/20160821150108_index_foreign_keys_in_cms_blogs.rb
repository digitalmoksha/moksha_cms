class IndexForeignKeysInCmsBlogs < ActiveRecord::Migration[4.2]
  def change
    add_index :cms_blogs, :account_id
    add_index :cms_blogs, :owner_id
  end
end
