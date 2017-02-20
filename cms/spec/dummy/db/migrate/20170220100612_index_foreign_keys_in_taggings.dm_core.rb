# This migration comes from dm_core (originally 20160821150130)
class IndexForeignKeysInTaggings < ActiveRecord::Migration
  def change
    add_index :taggings, :tagger_id
  end
end
