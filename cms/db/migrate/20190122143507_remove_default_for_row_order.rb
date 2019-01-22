class RemoveDefaultForRowOrder < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:cms_contentitems, :row_order, from: 0, to: nil)
  end
end
