# This migration comes from dm_core (originally 20160821150132)
class IndexForeignKeysInUserSiteProfiles < ActiveRecord::Migration
  def change
    add_index :user_site_profiles, :account_id
    add_index :user_site_profiles, :user_id
  end
end
