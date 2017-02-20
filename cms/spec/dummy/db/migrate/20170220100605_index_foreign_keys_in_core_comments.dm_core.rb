# This migration comes from dm_core (originally 20160821150115)
class IndexForeignKeysInCoreComments < ActiveRecord::Migration
  def change
    add_index :core_comments, :account_id
  end
end
