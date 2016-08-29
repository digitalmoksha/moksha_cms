class AddRequireAddress < ActiveRecord::Migration
  def change
    add_column    :ems_workshops, :require_account,     :boolean
    add_column    :ems_workshops, :require_address,     :boolean
    add_column    :ems_workshops, :require_photo,       :boolean
  end
end
