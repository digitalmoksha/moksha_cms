class IndexForeignKeysInCorePaymentHistories < ActiveRecord::Migration[4.2]
  def change
    add_index :core_payment_histories, :account_id
    add_index :core_payment_histories, :transaction_id
    add_index :core_payment_histories, :user_profile_id
  end
end
