# This migration comes from dm_core (originally 20130625091108)
class ChangeAnchorField < ActiveRecord::Migration
  def up
    change_column  :core_payment_histories, :anchor_id, :string, :limit => 20
  end

  def down
    change_column  :core_payment_histories, :anchor_id, :integer
  end
end
