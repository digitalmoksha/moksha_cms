class IndexForeignKeysInEmsWorkshopPriceTranslations < ActiveRecord::Migration[4.2]
  def change
    add_index :ems_workshop_price_translations, :ems_workshop_price_id
  end
end
