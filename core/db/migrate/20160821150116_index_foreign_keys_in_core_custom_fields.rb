class IndexForeignKeysInCoreCustomFields < ActiveRecord::Migration[4.2]
  def change
    add_index :core_custom_fields, :custom_field_def_id
  end
end
