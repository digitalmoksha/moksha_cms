class AddCmspageSummary < ActiveRecord::Migration
  def change
    add_column    :cms_pages,              :image,     :string
    add_column    :cms_page_translations,  :summary,   :text
  end
end
