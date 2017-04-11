class AddWorkshopCurrency < ActiveRecord::Migration[4.2]
  def change
    add_column   :ems_workshops, :base_currency, :string, :limit => 3
  end
end
