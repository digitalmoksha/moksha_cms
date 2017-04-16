class IndexForeignKeysInEmsWorkshopTranslations < ActiveRecord::Migration[4.2]
  def change
    add_index :ems_workshop_translations, :ems_workshop_id
  end
end
