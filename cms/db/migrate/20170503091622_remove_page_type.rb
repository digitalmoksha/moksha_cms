class RemovePageType < ActiveRecord::Migration[5.0]
  def up
    remove_column   :cms_pages, :pagetype
  end
  
  def down
    add_column      :cms_pages, :pagetype, limit: 20, default: "content", null: false
  end
end
