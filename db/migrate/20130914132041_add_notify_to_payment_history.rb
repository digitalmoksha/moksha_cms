class AddNotifyToPaymentHistory < ActiveRecord::Migration
  def change
    add_column      :core_payment_histories, :notify_data,      :text
    add_column      :core_payment_histories, :transaction_id,   :string
    rename_column   :core_payment_histories, :current_stage,    :status
  end
end
