class IndexForeignKeysInFmsForumTopics < ActiveRecord::Migration
  def change
    add_index :fms_forum_topics, :forum_id
    add_index :fms_forum_topics, :forum_site_id
    add_index :fms_forum_topics, :last_forum_comment_id
    add_index :fms_forum_topics, :last_user_id
    add_index :fms_forum_topics, :user_id
  end
end
