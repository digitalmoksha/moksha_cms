class AddSidebarToWorkshop < ActiveRecord::Migration
  def change
    add_column  :ems_workshop_translations, :sidebar, :text
  end
end
