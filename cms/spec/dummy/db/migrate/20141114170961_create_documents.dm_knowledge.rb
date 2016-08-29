# This migration comes from dm_knowledge (originally 20140918124007)
class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :knw_documents, :force => true do |t|
      t.string      :title
      t.string      :subtitle
      t.text        :content
      t.text        :summary
      t.datetime    :original_date
      t.boolean     :published
      t.boolean     :is_public
      t.boolean     :requires_login
      t.datetime    :updated_on
      t.datetime    :created_on
      t.integer     :account_id
      t.integer     :lock_version,                  :default => 0,         :null => false
    end
  end
end
