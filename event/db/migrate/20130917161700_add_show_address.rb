class AddShowAddress < ActiveRecord::Migration
  def change
    add_column   :ems_workshops, :show_address, :boolean
  end
end
