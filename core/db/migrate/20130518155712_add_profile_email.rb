class AddProfileEmail < ActiveRecord::Migration[4.2]
  def up
    add_column    :user_profiles,   :email,   :string
    User.all.find_each do |user|
      Account.current = Account.find(user.account_id)
      user.user_profile.update_attribute(:email, user.attributes['email'])
    end
  end

  def down
    remove_column :user_profiles,   :email
  end
end
