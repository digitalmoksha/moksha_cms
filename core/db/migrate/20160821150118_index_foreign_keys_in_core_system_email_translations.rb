class IndexForeignKeysInCoreSystemEmailTranslations < ActiveRecord::Migration[4.2]
  def change
    add_index :core_system_email_translations, :core_system_email_id
  end
end
