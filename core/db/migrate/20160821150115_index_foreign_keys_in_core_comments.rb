class IndexForeignKeysInCoreComments < ActiveRecord::Migration
  def change
    add_index :core_comments, :account_id
  end
end
