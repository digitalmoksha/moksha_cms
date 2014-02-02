class DeleteMonitorships < ActiveRecord::Migration
  def up
    drop_table :fms_monitorships
  end

  def down
    create_table :fms_monitorships, :force => true do |t|
      t.integer     :account_id
      t.integer     :user_id
      t.integer     :forum_topic_id
      t.datetime    :created_at
      t.datetime    :updated_at
      t.boolean     :active,     :default => true
    end
    add_index :fms_monitorships, :account_id
  end
end
