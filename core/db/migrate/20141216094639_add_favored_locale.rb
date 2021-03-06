class AddFavoredLocale < ActiveRecord::Migration[4.2]
  def up
    add_column :user_profiles, :favored_locale, :string

    locale_map = {'DE' => :de, 'AT' => :de, 'CH' => :de, 'JP' => :ja, 'FI' => :fi}
    us_country = DmCore::Country.find_by_code('US')
    UserProfile.all.find_each do |user_profile|
      user_profile.update_attribute(:country, us_country) if user_profile.country.nil?
      country_code = user_profile.country.code
      locale = locale_map[country_code].nil? ? :en : locale_map[country_code]
      user_profile.update_attribute(:favored_locale, locale)
    end
  end

  def down
    remove_column :user_profiles, :favored_locale
  end
end
