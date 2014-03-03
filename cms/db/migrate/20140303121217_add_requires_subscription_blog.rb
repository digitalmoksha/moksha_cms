class AddRequiresSubscriptionBlog < ActiveRecord::Migration
  def change
    add_column  :cms_blogs,   :requires_subscription,   :boolean
    add_column  :cms_pages,   :requires_subscription,   :boolean
    add_column  :cms_pages,   :is_public,               :boolean,   :default => true
  end
end
