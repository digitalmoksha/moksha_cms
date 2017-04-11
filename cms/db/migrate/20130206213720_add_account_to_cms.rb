class AddAccountToCms < ActiveRecord::Migration[4.2]
  def change
    add_column  :cms_pages,         :account_id, :integer
    add_index   :cms_pages,         :account_id
    add_column  :cms_contentitems,  :account_id, :integer
    add_index   :cms_contentitems,  :account_id
    add_column  :cms_snippets,      :account_id, :integer
    add_index   :cms_snippets,      :account_id
  end
end
