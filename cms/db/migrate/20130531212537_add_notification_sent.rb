class AddNotificationSent < ActiveRecord::Migration
  def change
    add_column  :cms_posts,   :notification_sent_on, :datetime
  end
end
