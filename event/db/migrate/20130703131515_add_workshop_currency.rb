class AddWorkshopCurrency < ActiveRecord::Migration
  def change
    add_column   :ems_workshops, :base_currency, :string, :limit => 3
  end
end
