# This migration comes from dm_cms (originally 20140303121217)
class AddRequiresSubscriptionBlog < ActiveRecord::Migration
  def change
    add_column  :cms_blogs,   :requires_subscription,   :boolean,   :default => false
    add_column  :cms_pages,   :requires_subscription,   :boolean,   :default => false
    add_column  :cms_pages,   :is_public,               :boolean,   :default => true
  end
end
