class CreateDmCoreAccounts < ActiveRecord::Migration
  def change
    create_table :core_accounts do |t|
      t.string    :company_name
      t.string    :contact_email
      t.string    :domain
      t.string    :account_prefix
      t.integer   :default_site_id
      t.timestamps null: true
    end
  end
end
