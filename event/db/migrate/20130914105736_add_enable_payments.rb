class AddEnablePayments < ActiveRecord::Migration[4.2]
  def change
    add_column   :ems_workshops, :payments_enabled,    :boolean
  end
end
