class AddAvatar < ActiveRecord::Migration
  def change
    add_column    :user_profiles, :public_avatar,                 :string
    add_column    :user_profiles, :public_avatar_file_size,       :integer
    add_column    :user_profiles, :public_avatar_content_type,    :string
    add_column    :user_profiles, :private_avatar,                :string
    add_column    :user_profiles, :private_avatar_file_size,      :integer
    add_column    :user_profiles, :private_avatar_content_type,   :string
    add_column    :user_profiles, :use_private_avatar_for_public, :boolean, :default => false
  end
end
