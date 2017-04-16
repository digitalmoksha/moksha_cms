class AddWelcomePage < ActiveRecord::Migration[4.2]
  def change
    add_column        :cms_pages, :welcome_page, :boolean, default: false
  end
end
