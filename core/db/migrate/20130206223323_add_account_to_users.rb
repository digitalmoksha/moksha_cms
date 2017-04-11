class AddAccountToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column  :users, :account_id, :integer
    add_index   :users, :account_id
    add_column  :roles, :account_id, :integer
    add_index   :roles, :account_id
  end
end
