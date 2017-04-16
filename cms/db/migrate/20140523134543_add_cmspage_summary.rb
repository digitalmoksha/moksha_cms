class AddCmspageSummary < ActiveRecord::Migration[4.2]
  def change
    add_column    :cms_pages,              :image,     :string
    add_column    :cms_page_translations,  :summary,   :text
  end
end
