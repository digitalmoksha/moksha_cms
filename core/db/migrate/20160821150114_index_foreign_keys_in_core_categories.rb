class IndexForeignKeysInCoreCategories < ActiveRecord::Migration
  def change
    add_index :core_categories, :account_id
  end
end
