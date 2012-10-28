class AddUserFields < ActiveRecord::Migration
  def up
    add_column :users, :first_name,           :string
    add_column :users, :last_name,            :string
    add_column :users, :country_id,           :integer
  end

  def down
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :country_id
  end
end
