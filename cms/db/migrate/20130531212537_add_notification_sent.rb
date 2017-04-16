class AddNotificationSent < ActiveRecord::Migration[4.2]
  def change
    add_column  :cms_posts,   :notification_sent_on, :datetime
  end
end
