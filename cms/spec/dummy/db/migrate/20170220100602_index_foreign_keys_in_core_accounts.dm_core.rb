# This migration comes from dm_core (originally 20160821150111)
class IndexForeignKeysInCoreAccounts < ActiveRecord::Migration
  def change
    add_index :core_accounts, :default_site_id
  end
end
