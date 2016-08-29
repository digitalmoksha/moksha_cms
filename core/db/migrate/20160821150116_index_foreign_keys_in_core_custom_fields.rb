class IndexForeignKeysInCoreCustomFields < ActiveRecord::Migration
  def change
    add_index :core_custom_fields, :custom_field_def_id
  end
end
