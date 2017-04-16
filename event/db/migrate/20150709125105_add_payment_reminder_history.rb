class AddPaymentReminderHistory < ActiveRecord::Migration[4.2]
  def up
    add_column :ems_registrations, :payment_reminder_history, :text

    Registration.unscoped.each do |r|
      Account.current = Account.find(r.account_id)
      if r.payment_reminder_sent_on
        r.update_attribute(:payment_reminder_history,  [r.payment_reminder_sent_on])
      end
    end
  end

  def down
    remove_column :ems_registrations, :payment_reminder_history
  end
end
