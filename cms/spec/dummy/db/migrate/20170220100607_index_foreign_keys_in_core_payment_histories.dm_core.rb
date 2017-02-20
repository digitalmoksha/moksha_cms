# This migration comes from dm_core (originally 20160821150117)
class IndexForeignKeysInCorePaymentHistories < ActiveRecord::Migration
  def change
    add_index :core_payment_histories, :account_id
    add_index :core_payment_histories, :transaction_id
    add_index :core_payment_histories, :user_profile_id
  end
end
