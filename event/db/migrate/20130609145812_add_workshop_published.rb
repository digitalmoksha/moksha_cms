class AddWorkshopPublished < ActiveRecord::Migration
  def change
    rename_column :ems_workshops, :is_closed, :published
  end
end
