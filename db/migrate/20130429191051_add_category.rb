class AddCategory < ActiveRecord::Migration
  def up
    create_table "core_category_translations", :force => true do |t|
      t.integer     :core_category_id
      t.string      :locale
      t.string      :name
      t.string      :description
      t.datetime    :created_at
      t.datetime    :updated_at
    end

    add_index "core_category_translations", ["core_category_id"], :name => "index_category_translation"

    create_table "core_categories", :force => true do |t|
      t.string      :type
      t.integer     :row_order
      t.integer     :account_id
      t.datetime    :created_on
      t.datetime    :updated_on
    end
  end

  def down
    drop_table      :core_categories
    drop_table      :core_category_translations
  end
end
