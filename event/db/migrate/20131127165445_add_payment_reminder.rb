class AddPaymentReminder < ActiveRecord::Migration[4.2]
  def change
    add_column   :ems_registrations, :payment_reminder_sent_on, :datetime, :default => nil
  end
end
