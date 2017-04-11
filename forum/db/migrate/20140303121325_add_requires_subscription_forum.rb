class AddRequiresSubscriptionForum < ActiveRecord::Migration[4.2]
  def change
    add_column  :fms_forums,   :requires_subscription,   :boolean,   :default => false
  end
end
