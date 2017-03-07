# This migration comes from dm_core (originally 20130206223323)
class AddAccountToUsers < ActiveRecord::Migration
  def change
    add_column  :users, :account_id, :integer
    add_index   :users, :account_id
    add_column  :roles, :account_id, :integer
    add_index   :roles, :account_id
  end
end
