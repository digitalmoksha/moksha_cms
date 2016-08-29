# This migration comes from dm_core (originally 20130402203739)
class AddActivity < ActiveRecord::Migration
  def change
    create_table :core_activities do |t|
      t.integer       :account_id
      t.references    :user
      t.string        :browser
      t.string        :session_id
      t.string        :ip_address
      t.string        :controller
      t.string        :action
      t.string        :params
      t.string        :slug
      t.string        :lesson
      t.datetime      :created_at
    end

    add_index :core_activities, :account_id
    add_index :core_activities, :user_id
  end
end
