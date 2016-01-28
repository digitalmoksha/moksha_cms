# This migration comes from dm_core (originally 20130207170247)
class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.string      :name, :null => false
      t.references  :owner, :polymorphic => true, :null => false
      t.references  :group, :polymorphic => true
      t.string      :value
      t.timestamps null: true
    end
    add_index :preferences, [:owner_id, :owner_type, :name, :group_id, :group_type], :unique => true, :name => 'index_preferences_on_owner_and_name_and_preference'
  end
end
