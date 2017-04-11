class CreateMediaFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :cms_media_files do |t|
      t.string    :media
      t.integer   :media_file_size
      t.string    :media_content_type
      t.string    :folder
      t.boolean   :generate_retina
      t.integer   :user_id
      t.datetime  :created_at
      t.datetime  :updated_at
      t.integer   :account_id
    end

    add_index :cms_media_files, [:media, :folder, :account_id], unique: true, name: "index_media_folder_account_id"

    create_table :cms_media_file_translations, :force => true do |t|
      t.integer     :cms_media_file_id
      t.string      :locale
      t.string      :title
      t.string      :description
      t.datetime    :created_at
      t.datetime    :updated_at
    end

    add_index :cms_media_file_translations, [:cms_media_file_id], name: "index_cms_media_file_translations_on_cms_media_file_id"

  end
end
