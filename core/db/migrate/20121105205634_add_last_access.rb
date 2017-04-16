class AddLastAccess < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :last_access_at,           :datetime
  end

  def down
    remove_column :users, :last_access_at
  end
end
