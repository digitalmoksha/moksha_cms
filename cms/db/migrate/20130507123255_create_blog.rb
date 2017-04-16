class CreateBlog < ActiveRecord::Migration[4.2]
  def up
    create_table :cms_blog_translations, :force => true do |t|
      t.integer     :cms_blog_id
      t.string      :locale
      t.string      :title
      t.datetime    :created_at
      t.datetime    :updated_at
    end

    add_index :cms_blog_translations, ["cms_blog_id"], :name => "index_cms_blog_translations_on_cms_blog_id"

    create_table :cms_blogs, :force => true do |t|
      t.string      :slug
      t.boolean     :published,                     :default => false
      t.boolean     :is_public,                     :default => false
      t.boolean     :requires_login,                :default => false
      t.integer     :row_order
      t.datetime    :updated_on
      t.datetime    :created_on
      t.integer     :account_id
      t.integer     :lock_version,                  :default => 0,         :null => false
    end

    add_index :cms_blogs, ["slug"], :name => "blogname_key"
    add_index :cms_blogs, ["published"], :name => "cms_blogs_published_index"

    create_table :cms_post_translations, :force => true do |t|
      t.integer     :cms_post_id
      t.string      :locale
      t.string      :title
      t.text        :content
      t.text        :summary
      t.datetime    :created_at
      t.datetime    :updated_at
    end

    add_index :cms_post_translations, ["cms_post_id"], :name => "index_cms_post_translations_on_cms_post_id"

    create_table :cms_posts, :force => true do |t|
      t.string      :slug
      t.integer     :cms_blog_id
      t.string      :image
      t.datetime    :published_on
      t.datetime    :updated_on
      t.datetime    :created_on
      t.integer     :account_id
      t.integer     :lock_version,                  :default => 0,         :null => false
    end

    add_index :cms_posts, ["slug"], :name => "postname_key"
    add_index :cms_posts, ["published_on"], :name => "cms_posts_published_index"
  end

  def down
    drop_table      :cms_blogs
    drop_table      :cms_blog_translations
    drop_table      :cms_posts
    drop_table      :cms_post_translations
  end
end
