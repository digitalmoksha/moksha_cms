class AddSidebarToWorkshop < ActiveRecord::Migration[4.2]
  def change
    add_column  :ems_workshop_translations, :sidebar, :text
  end
end
