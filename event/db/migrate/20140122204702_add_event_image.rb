class AddEventImage < ActiveRecord::Migration[4.2]
  def change
    add_column    :ems_workshops, :image, :string
  end
end
