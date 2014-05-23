class AddWorkshopSummary < ActiveRecord::Migration
  def change
    add_column    :ems_workshop_translations,  :summary,   :text
  end
end
