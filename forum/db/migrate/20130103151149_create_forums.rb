class CreateForums < ActiveRecord::Migration[4.2]
  def up

    create_table :fms_forums, :force => true do |t|
      t.integer     :account_id
      t.integer     :forum_site_id
      t.string      :name
      t.text        :description
      t.integer     :forum_topics_count,      :default => 0
      t.integer     :comments_count,          :default => 0
      t.integer     :row_order,               :default => 0
      t.text        :description_html
      t.string      :state,                   :default => "public"
      t.boolean     :published,               :default => false
      t.string      :slug
    end
    add_index :fms_forums, [:account_id, :slug]

    create_table :fms_monitorships, :force => true do |t|
      t.integer     :account_id
      t.integer     :user_id
      t.integer     :forum_topic_id
      t.datetime    :created_at
      t.datetime    :updated_at
      t.boolean     :active,     :default => true
    end
    add_index :fms_monitorships, :account_id

    create_table :fms_forum_sites, :force => true do |t|
      t.integer     :account_id
      t.boolean     :enabled,             :default => false
      t.datetime    :created_at
      t.datetime    :updated_at
      t.integer     :forum_topics_count,  :default => 0
      t.integer     :comments_count,      :default => 0
      t.integer     :users_count,         :default => 0
      t.text        :description
      t.text        :tagline
    end

    create_table :fms_forum_topics, :force => true do |t|
      t.integer     :account_id
      t.integer     :forum_id
      t.integer     :user_id
      t.string      :title
      t.datetime    :created_at
      t.datetime    :updated_at
      t.integer     :hits,              :default => 0
      t.boolean     :sticky,            :default => false
      t.integer     :comments_count,    :default => 0
      t.boolean     :locked,            :default => false
      t.integer     :last_forum_comment_id
      t.datetime    :last_updated_at
      t.integer     :last_user_id
      t.integer     :forum_site_id
      t.string      :slug
    end

    add_index :fms_forum_topics, [:account_id, :forum_id, :slug]
    add_index :fms_forum_topics, [:account_id, :last_updated_at, :forum_id], :name => 'index_forum_topics_last_updated_at_forum_id'
    add_index :fms_forum_topics, [:account_id, :sticky, :last_updated_at, :forum_id], :name => 'index_forum_topics_sticky_last_updated_at_forum_id'

  end

  def down
    drop_table  :fms_forums
    drop_table  :fms_moderatorships
    drop_table  :fms_monitorships
    drop_table  :fms_forum_sites
    drop_table  :fms_forum_topics
  end
end
