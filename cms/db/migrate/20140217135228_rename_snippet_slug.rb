class RenameSnippetSlug < ActiveRecord::Migration
  def up
    change_column :cms_snippets, :itemtype, :string, :default => 'markdown'
    rename_column :cms_snippets, :container, :slug
    add_index     :cms_snippets, :slug
  end

  def down
    change_column :cms_snippets, :itemtype, :string, :default => 'textile'
    rename_column :cms_snippets, :slug, :container
    remove_index  :cms_snippets, :slug
  end
end
