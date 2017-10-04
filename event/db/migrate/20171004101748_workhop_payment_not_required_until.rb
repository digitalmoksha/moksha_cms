class WorkhopPaymentNotRequiredUntil < ActiveRecord::Migration[5.0]
  def change
    add_column :ems_workshops, :initial_payment_required_on, :date
  end
end
