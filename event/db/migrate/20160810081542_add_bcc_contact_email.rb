class AddBccContactEmail < ActiveRecord::Migration
  def change
    add_column    :ems_workshops, :bcc_contact_email, :boolean, default: false
  end
end
