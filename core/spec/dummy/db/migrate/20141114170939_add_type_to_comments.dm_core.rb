# This migration comes from dm_core (originally 20130415095617)
class AddTypeToComments < ActiveRecord::Migration
  def change
    add_column    :core_comments,     :type, :string
    add_column    :core_comments,     :ancestry, :string
    add_column    :core_comments,     :ancestry_depth, :integer, :default => 0
    rename_column :core_comments,     :comment, :body
  end
end
