class AddWorkshopSummary < ActiveRecord::Migration[4.2]
  def change
    add_column    :ems_workshop_translations,  :summary,   :text
  end
end
