class CreateCustomFields < ActiveRecord::Migration
  def change
    create_table :core_custom_field_defs do |t|
      t.references    :owner, polymorphic: true
      t.string        :name
      t.string        :field_type
      t.integer       :row_order
      t.boolean       :required,        default: false
      t.string        :properties,      limit: 2048
      t.timestamps
      t.integer       :account_id
    end

    add_index :core_custom_field_defs, :account_id
    add_index :core_custom_field_defs, [:owner_id, :owner_type]

    create_table :core_custom_field_def_translations, force: true do |t|
      t.integer     :core_custom_field_def_id
      t.string      :locale
      t.string      :label
      t.text        :description
      t.datetime    :created_at
      t.datetime    :updated_at
    end

    add_index :core_custom_field_def_translations, [:core_custom_field_def_id], name: 'core_custom_field_def_translations_index'

    create_table :core_custom_fields do |t|
      t.references    :owner, polymorphic: true
      t.integer       :custom_field_def_id
      t.string        :field_data,     limit: 4096
      t.timestamps
      t.integer       :account_id
    end

    add_index :core_custom_fields, :account_id
    add_index :core_custom_fields, [:owner_id, :owner_type]
  end
end
