# This migration comes from dm_core (originally 20130513112751)
class CreateEmailTable < ActiveRecord::Migration
  def up
    create_table :core_system_email_translations, :force => true do |t|
      t.integer     :core_system_email_id
      t.string      :locale
      t.string      :subject
      t.text        :body
      t.datetime    :created_at
      t.datetime    :updated_at
    end

    create_table :core_system_emails, :force => true do |t|
      t.string      :email_type
      t.references  :emailable, :polymorphic => true
      t.datetime    :created_at
      t.datetime    :updated_at
      t.integer     :account_id
    end
  end

  def down
    drop_table    :core_system_emails
    drop_table    :core_system_email_translations
  end
end
