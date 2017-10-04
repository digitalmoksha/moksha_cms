class RemoveEventPreferences < ActiveRecord::Migration[5.0]
  def up
    add_column :ems_registrations, :payment_reminder_hold_until, :date
    Registration.unscoped.each do |r|
      Account.current = Account.find(r.account_id)
      pref = Preference.where(owner: r, name: 'payment_reminder_hold_until').first
      if pref
        r.update_attribute(:payment_reminder_hold_until, pref.value)
        pref.destroy
      end
    end

    add_column :ems_workshops, :show_social_buttons, :boolean, default: false
    add_column :ems_workshops, :header_accent_color, :string
    Workshop.unscoped.each do |w|
      Account.current = Account.find(w.account_id)
      pref = Preference.where(owner: w, name: 'show_social_buttons').first
      if pref
        w.update_attribute(:show_social_buttons, pref.value)
        pref.destroy
      end

      pref = Preference.where(owner: w, name: 'header_accent_color').first
      if pref
        w.update_attribute(:header_accent_color, pref.value)
        pref.destroy
      end
    end
  end
  
  def down
    Registration.unscoped.each do |r|
      Account.current = Account.find(r.account_id)
      Preference.create(owner: r, name: 'payment_reminder_hold_until', value: r.payment_reminder_hold_until) if r.payment_reminder_hold_until
    end
    remove_column :ems_registrations, :payment_reminder_hold_until

    Workshop.unscoped.each do |w|
      Account.current = Account.find(w.account_id)
      Preference.create(owner: w, name: 'show_social_buttons', value: w.show_social_buttons)
      Preference.create(owner: w, name: 'header_accent_color', value: w.header_accent_color) unless w.header_accent_color.blank?
    end
    remove_column :ems_workshops, :show_social_buttons
    remove_column :ems_workshops, :header_accent_color
  end
end
