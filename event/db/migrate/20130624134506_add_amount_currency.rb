class AddAmountCurrency < ActiveRecord::Migration
  def up
    rename_column   :ems_registrations, :amount, :amount_paid_cents
    add_column      :ems_registrations, :amount_paid_currency, :string
    
    Registration.unscoped.all.each do |r|
      Account.current = Account.find(r.account_id)
      r.update_attribute(:amount_paid_currency, r.workshop_price.price_currency)
    end
  end

  def down
    rename_column   :ems_registrations, :amount_paid_cents, :amount
    remove_column   :ems_registrations, :amount_paid_currency
  end
end
