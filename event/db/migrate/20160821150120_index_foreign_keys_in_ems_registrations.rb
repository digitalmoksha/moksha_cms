class IndexForeignKeysInEmsRegistrations < ActiveRecord::Migration[4.2]
  def change
    add_index :ems_registrations, :account_id
    add_index :ems_registrations, :payment_comment_id
    add_index :ems_registrations, :user_profile_id
    add_index :ems_registrations, :workshop_id
    add_index :ems_registrations, :workshop_price_id
  end
end
