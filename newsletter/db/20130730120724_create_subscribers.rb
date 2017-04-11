class CreateSubscribers < ActiveRecord::Migration[4.2]
  def change
    create_table 'email_subscriptions', :force => true do |t|
      t.string    'token'               # url friendly unique subscriber id, similar to mc_id
      t.integer   'newsletter_id'
      t.integer   'user_profile_id'
      t.string    'email'
      t.string    'first_name'
      t.string    'last_name'
      t.string    'country',            :limit => 2
      t.string    'confirmation_code'
      t.string    'subscribed_ip'       # IP address subscribed from
      t.datetime  'subscribed_on'       # Date subscirbed on
      t.string    'confirmed_ip'        # IP confirmed from
      t.datetime  'confirmed_on'        # Date confirmed
      t.string    'status'              # pending, subscribed, unsubscribed, cleaned
      t.datetime  'status_changed_on'   # Date status was changed
      t.datetime  'created_at'
      t.datetime  'updated_at'
      t.integer   'account_id'
      
      #--- Mailchimp specific fields
      t.string    'mc_id'               # unique id (euid) for this email address on an account
      t.string    'mc_email_type'       # type of requested email: html or text
      t.integer   'mc_web_id'           # ember id in MC, allows you to create a link directly to it
    end
    add_index 'email_subscriptions', ['account_id', 'newsletter_id']
    add_index 'email_subscriptions', ['account_id', 'email']
    add_index 'email_subscriptions', ['mc_id']
    
  end
end
