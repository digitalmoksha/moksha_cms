class CreateNewsletter < ActiveRecord::Migration[4.2]
  def change
    create_table 'email_newsletters', :force => true do |t|
      t.string    'token'                 # url friendly unique list id, similar to mc_id
      t.string    'name'
      t.boolean   'require_name',         :default => false
      t.boolean   'require_country',      :default => false
      t.integer   'subscribed_count',     :default => 0
      t.integer   'unsubscribed_count',   :default => 0
      t.integer   'cleaned_count',        :default => 0
      t.datetime  'created_at'
      t.datetime  'updated_at'
      t.integer   'account_id'
      t.string    'type'
      
      #--- MailChimp specific fields
      t.string    'mc_id'
      t.boolean   'deleted',              :default => false  # set if list was deleted at MC
    end
    add_index 'email_newsletters', ['account_id']
    add_index 'email_newsletters', ['token']
    add_index 'email_newsletters', ['mc_id']
  end
end
