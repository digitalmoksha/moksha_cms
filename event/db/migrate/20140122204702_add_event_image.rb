class AddEventImage < ActiveRecord::Migration
  def change
    add_column    :ems_workshops, :image, :string
  end
end
