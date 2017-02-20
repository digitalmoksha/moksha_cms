# This migration comes from dm_core (originally 20160821150118)
class IndexForeignKeysInCoreSystemEmailTranslations < ActiveRecord::Migration
  def change
    add_index :core_system_email_translations, :core_system_email_id
  end
end
