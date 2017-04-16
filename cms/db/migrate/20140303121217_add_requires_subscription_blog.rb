class AddRequiresSubscriptionBlog < ActiveRecord::Migration[4.2]
  def change
    add_column  :cms_blogs,   :requires_subscription,   :boolean,   :default => false
    add_column  :cms_pages,   :requires_subscription,   :boolean,   :default => false
    add_column  :cms_pages,   :is_public,               :boolean,   :default => true
  end
end
