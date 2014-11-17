# This migration comes from dm_core (originally 20140107112418)
class UserSiteProfile < ActiveRecord::Base
end

class AddUserSiteProfileUuid < ActiveRecord::Migration
  def up
    add_column  :user_site_profiles,  :uuid,   :string,  :limit => 40
    add_index   :user_site_profiles,  :uuid
    
    #--- Create uuid for existing records
    UserSiteProfile.all.each do |profile|
      profile.update_attribute(:uuid, SecureRandom.uuid)
    end
  end
  
  def down
    remove_column  :user_site_profiles,  :uuid
  end
end
