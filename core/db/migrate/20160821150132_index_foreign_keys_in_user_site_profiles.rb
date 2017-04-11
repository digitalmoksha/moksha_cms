class IndexForeignKeysInUserSiteProfiles < ActiveRecord::Migration[4.2]
  def change
    add_index :user_site_profiles, :account_id
    add_index :user_site_profiles, :user_id
  end
end
