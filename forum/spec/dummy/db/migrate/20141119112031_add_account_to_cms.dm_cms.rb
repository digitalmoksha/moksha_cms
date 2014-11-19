# This migration comes from dm_cms (originally 20130206213720)
class AddAccountToCms < ActiveRecord::Migration
  def change
    add_column  :cms_pages,         :account_id, :integer
    add_index   :cms_pages,         :account_id
    add_column  :cms_contentitems,  :account_id, :integer
    add_index   :cms_contentitems,  :account_id
    add_column  :cms_snippets,      :account_id, :integer
    add_index   :cms_snippets,      :account_id
  end
end
