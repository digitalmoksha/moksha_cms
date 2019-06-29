class WorkshopAddHideDates < ActiveRecord::Migration[5.0]
  def change
    add_column :ems_workshops, :hide_dates, :boolean, default: false
  end
end
