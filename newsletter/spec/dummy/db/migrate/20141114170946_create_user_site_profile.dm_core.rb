# This migration comes from dm_core (originally 20130628112848)
class CreateUserSiteProfile < ActiveRecord::Migration
  def up
    create_table :user_site_profiles, :force => true do |t|
      t.integer     :user_id
      t.datetime    :last_access_at
      t.datetime    :created_at
      t.datetime    :updated_at
      t.integer     :account_id
    end

    User.all.find_each do |user|
      Account.current = Account.find(user.account_id)
      p = user.user_site_profiles.create
      p.update_attribute(:account_id, user.attributes['account_id']) 
      p.update_attribute(:last_access_at, user.user_profile.attributes['last_access_at'])
      p.update_attribute(:created_at, user.attributes['created_at'])
      p.update_attribute(:updated_at, user.attributes['updated_at'])
    end
    remove_column  :user_profiles, :last_access_at
  end

  def down
    drop_table  :user_site_profiles
    add_column  :user_profiles, :last_access_at, :datetime
  end
end
