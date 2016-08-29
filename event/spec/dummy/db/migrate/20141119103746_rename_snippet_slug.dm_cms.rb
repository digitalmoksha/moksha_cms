# This migration comes from dm_cms (originally 20140217135228)
class RenameSnippetSlug < ActiveRecord::Migration
  def up
    change_column :cms_snippets, :itemtype, :string, :default => 'markdown'
    rename_column :cms_snippets, :container, :slug
    rename_index  :cms_snippets, 'index_cms_snippets_on_container', 'index_cms_snippets_on_slug'
  end

  def down
    change_column :cms_snippets, :itemtype, :string, :default => 'textile'
    rename_column :cms_snippets, :slug, :container
    rename_index  :cms_snippets, 'index_cms_snippets_on_slug', 'index_cms_snippets_on_container'
  end
end
