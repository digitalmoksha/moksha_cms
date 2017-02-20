class AddWelcomePage < ActiveRecord::Migration
  def change
    add_column        :cms_pages, :welcome_page, :boolean, default: false
  end
end
