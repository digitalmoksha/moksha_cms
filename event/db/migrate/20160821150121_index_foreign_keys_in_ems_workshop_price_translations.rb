class IndexForeignKeysInEmsWorkshopPriceTranslations < ActiveRecord::Migration
  def change
    add_index :ems_workshop_price_translations, :ems_workshop_price_id
  end
end
