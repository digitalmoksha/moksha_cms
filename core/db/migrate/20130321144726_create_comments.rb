class CreateComments < ActiveRecord::Migration[4.2]
  def self.up
    create_table :core_comments do |t|
      t.string        :title, :limit => 50, :default => "" 
      t.text          :comment
      t.references    :commentable, :polymorphic => true
      t.references    :user
      t.string        :role, :default => "comments"
      t.integer       :account_id
      t.timestamps null: true
    end

    add_index :core_comments, :commentable_type
    add_index :core_comments, :commentable_id
    add_index :core_comments, :user_id
  end

  def self.down
    drop_table :core_comments
  end
end
