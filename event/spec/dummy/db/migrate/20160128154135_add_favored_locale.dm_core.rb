# This migration comes from dm_core (originally 20141216094639)
class AddFavoredLocale < ActiveRecord::Migration
  def up
    add_column :user_profiles, :favored_locale, :string

    locale_map = {'DE' => :de, 'AT' => :de, 'CH' => :de, 'JP' => :ja, 'FI' => :fi}
    UserProfile.all.find_each do |user_profile|
      country_code = user_profile.country.code
      locale = locale_map[country_code].nil? ? :en : locale_map[country_code]
      user_profile.update_attribute(:favored_locale, locale)
    end
  end

  def down
    remove_column :user_profiles, :favored_locale
  end
end
