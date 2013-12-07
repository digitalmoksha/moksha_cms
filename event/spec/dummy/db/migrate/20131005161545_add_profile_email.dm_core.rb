# This migration comes from dm_core (originally 20130518155712)
class AddProfileEmail < ActiveRecord::Migration
  def up
    add_column    :user_profiles,   :email,   :string
    User.find(:all).each do |user|
      Account.current = Account.find(user.account_id)
      user.user_profile.update_attribute(:email, user.attributes['email'])
    end
  end

  def down
    remove_column :user_profiles,   :email
  end
end
