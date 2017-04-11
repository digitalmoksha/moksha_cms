class IndexForeignKeysInCoreComments < ActiveRecord::Migration[4.2]
  def change
    add_index :core_comments, :account_id
  end
end
