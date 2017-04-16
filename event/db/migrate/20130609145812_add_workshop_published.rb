class AddWorkshopPublished < ActiveRecord::Migration[4.2]
  def change
    rename_column :ems_workshops, :is_closed, :published
  end
end
