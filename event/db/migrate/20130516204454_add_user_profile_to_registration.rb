class AddUserProfileToRegistration < ActiveRecord::Migration[4.2]
  def up
    add_column      :ems_registrations, :user_profile_id, :integer
    remove_column   :ems_registrations, :user_id
  end

  def down
    remove_column   :ems_registrations, :user_profile_id
    add_column      :ems_registrations, :user_id, :integer
  end
end
