class AddPaymentReminder < ActiveRecord::Migration
  def change
    add_column   :ems_registrations, :payment_reminder_sent_on, :datetime, :default => nil
  end
end
