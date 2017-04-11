class IndexForeignKeysInCoreCategories < ActiveRecord::Migration[4.2]
  def change
    add_index :core_categories, :account_id
  end
end
