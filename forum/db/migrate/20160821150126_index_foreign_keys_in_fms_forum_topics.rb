class IndexForeignKeysInFmsForumTopics < ActiveRecord::Migration[4.2]
  def change
    add_index :fms_forum_topics, :forum_id
    add_index :fms_forum_topics, :forum_site_id
    add_index :fms_forum_topics, :last_forum_comment_id
    add_index :fms_forum_topics, :last_user_id
    add_index :fms_forum_topics, :user_id
  end
end
