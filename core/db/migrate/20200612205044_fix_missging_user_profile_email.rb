class FixMissgingUserProfileEmail < ActiveRecord::Migration[5.2]
  def up
    UserProfile.unscoped.where(email: nil).each do |user_profile|
      if user_profile.user
        user_profile.update_attribute(:email, user_profile.user.email)
      end
    end
  end

  def down
  end
end
