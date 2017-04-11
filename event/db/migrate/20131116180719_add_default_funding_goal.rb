class AddDefaultFundingGoal < ActiveRecord::Migration[4.2]
  def up
    change_column :ems_workshops, :funding_goal_cents, :integer, :default => 0
  end

  def down
  end
end
