class AddRequiresSubscriptionForum < ActiveRecord::Migration
  def change
    add_column  :fms_forums,   :requires_subscription,   :boolean,   :default => false
  end
end