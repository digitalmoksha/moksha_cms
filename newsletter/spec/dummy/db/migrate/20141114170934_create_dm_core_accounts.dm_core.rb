# This migration comes from dm_core (originally 20130206121535)
class CreateDmCoreAccounts < ActiveRecord::Migration
  def change
    create_table :core_accounts do |t|
      t.string    :company_name
      t.string    :contact_email
      t.string    :domain
      t.string    :account_prefix
      t.integer   :default_site_id
      t.timestamps
    end
  end
end
