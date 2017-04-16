class IndexForeignKeysInEmsWorkshopPrices < ActiveRecord::Migration[4.2]
  def change
    add_index :ems_workshop_prices, :account_id
    add_index :ems_workshop_prices, :workshop_id
  end
end
