# This migration comes from dm_core (originally 20130516143539)
class AddUserProfile < ActiveRecord::Migration
  def up
    create_table :user_profiles, :force => true do |t|
      t.integer     :user_id
      t.string      :public_name,         :limit => 50, :default => ""
      t.string      :first_name,          :limit => 50, :default => ""
      t.string      :last_name,           :limit => 50, :default => ""
      t.string      :address,             :limit => 70, :default => ""
      t.string      :address2,            :limit => 70, :default => ""
      t.string      :city,                :limit => 30, :default => ""
      t.string      :state,               :limit => 30, :default => ""
      t.string      :zipcode,             :limit => 10, :default => ""
      t.integer     :country_id,                        :default => 0
      t.string      :phone,               :limit => 20, :default => ""
      t.string      :cell,                :limit => 20, :default => ""
      t.string      :fax,                 :limit => 20, :default => ""
      t.string      :workphone,           :limit => 20, :default => ""
      t.string      :website,             :limit => 50, :default => ""
      t.string      :gender,              :limit => 1,  :default => ""
      t.integer     :status,                            :default => 0
      t.integer     :lock_version,                      :default => 0
      t.datetime    :last_access_at
      t.datetime    :created_at
      t.datetime    :updated_at
      t.integer     :account_id
    end
    
    User.find(:all).each do |user|
      Account.current = Account.find(user.account_id)
      p = user.create_user_profile
      p.update_attributes(first_name: user.attributes['first_name'], last_name: user.attributes['last_name'],
                          country_id: user.attributes['country_id'],
                          public_name: "#{user.attributes['first_name']}")
      p.update_attribute(:last_access_at, user.attributes['last_access_at'])
    end
    remove_column   :users, :first_name
    remove_column   :users, :last_name
    remove_column   :users, :country_id
    remove_column   :users, :last_access_at
  end

  def down
    drop_table    :user_profiles
  end
end
