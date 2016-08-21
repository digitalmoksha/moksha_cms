class IndexForeignKeysInEmsWorkshopPrices < ActiveRecord::Migration
  def change
    add_index :ems_workshop_prices, :account_id
    add_index :ems_workshop_prices, :workshop_id
  end
end
