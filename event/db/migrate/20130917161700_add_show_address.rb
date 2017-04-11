class AddShowAddress < ActiveRecord::Migration[4.2]
  def change
    add_column   :ems_workshops, :show_address, :boolean
  end
end
