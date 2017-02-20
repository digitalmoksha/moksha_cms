# This migration comes from dm_core (originally 20160821150114)
class IndexForeignKeysInCoreCategories < ActiveRecord::Migration
  def change
    add_index :core_categories, :account_id
  end
end
