class IndexForeignKeysInUserProfiles < ActiveRecord::Migration[4.2]
  def change
    add_index :user_profiles, :account_id
    add_index :user_profiles, :country_id
    add_index :user_profiles, :user_id
  end
end
