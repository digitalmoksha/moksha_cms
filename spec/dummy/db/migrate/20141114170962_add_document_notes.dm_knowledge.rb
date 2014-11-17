# This migration comes from dm_knowledge (originally 20141031143619)
class AddDocumentNotes < ActiveRecord::Migration
  def change
    add_column    :knw_documents, :slug,    :string
    add_column    :knw_documents, :notes,   :text
  end
end
