class RemoveDefaultForRowOrderFms < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:fms_forums, :row_order, from: 0, to: nil)
  end
end
