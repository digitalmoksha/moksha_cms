class AddEnablePayments < ActiveRecord::Migration
  def change
    add_column   :ems_workshops, :payments_enabled,    :boolean
  end
end
