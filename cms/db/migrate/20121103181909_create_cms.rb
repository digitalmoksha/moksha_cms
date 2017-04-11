class CreateCms < ActiveRecord::Migration[4.2]
  def up
    create_table "cms_contentitem_translations", :force => true do |t|
      t.integer  "cms_contentitem_id"
      t.string   "locale"
      t.text     "content"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "cms_contentitem_translations", ["cms_contentitem_id"], :name => "index_072c3a76f87c96e2f91149eccd2a283dca2b613f"

    create_table "cms_contentitems", :force => true do |t|
      t.integer  "cms_page_id"
      t.string   "itemtype",     :limit => 30, :default => "textile"
      t.string   "container",    :limit => 30
      t.integer  "position",                   :default => 0
      t.boolean  "enable_cache",               :default => true,      :null => false
      t.datetime "created_on"
      t.datetime "updated_on"
      t.integer  "lock_version",               :default => 0
    end

    add_index "cms_contentitems", ["cms_page_id"], :name => "cms_contentitems_cms_page_id_index"

    create_table "cms_page_translations", :force => true do |t|
      t.integer  "cms_page_id"
      t.string   "locale"
      t.string   "title"
      t.string   "menutitle"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "cms_page_translations", ["cms_page_id"], :name => "index_cms_page_translations_on_cms_page_id"

    create_table "cms_pages", :force => true do |t|
      t.string   "slug",            :limit => 50, :default => "",        :null => false
      t.string   "pagetype",        :limit => 20, :default => "content", :null => false
      t.boolean  "published",                     :default => false,     :null => false
      t.string   "template",        :limit => 50, :default => "",        :null => false
      t.string   "link",                          :default => "",        :null => false
      t.string   "menuimage"
      t.boolean  "requires_login",                :default => false
      t.string   "ancestry"
      t.integer  'ancestry_depth',                :default => 0
      t.integer  'position'
      t.datetime "updated_on"
      t.datetime "created_on"
      t.integer  "lock_version",                  :default => 0,         :null => false
    end

    add_index "cms_pages", ["slug"], :name => "pagename_key"
    add_index "cms_pages", "ancestry"
    add_index "cms_pages", "ancestry_depth"
    add_index "cms_pages", ["published"], :name => "cms_pages_published_index"

    create_table "cms_snippet_translations", :force => true do |t|
      t.integer  "cms_snippet_id"
      t.string   "locale"
      t.text     "content"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "cms_snippet_translations", ["cms_snippet_id"], :name => "index_cms_snippet_translations_on_cms_snippet_id"

    create_table "cms_snippets", :force => true do |t|
      t.string   "itemtype",     :limit => 30, :default => "textile"
      t.string   "container"
      t.string   "description"
      t.boolean  "enable_cache",               :default => true,      :null => false
      t.boolean  "published",                  :default => true,      :null => false
      t.datetime "created_on"
      t.datetime "updated_on"
      t.integer  "lock_version",               :default => 0
    end

    add_index "cms_snippets", ["container"], :name => "index_cms_snippets_on_container"

  end

  def down
    drop_table  :cms_snippets
    drop_table  :cms_snippet_translations
    drop_table  :cms_pages
    drop_table  :cms_page_translations
    drop_table  :cms_contentitems
    drop_table  :cms_contentitem_translations
  end
end
