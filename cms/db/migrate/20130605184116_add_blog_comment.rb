class AddBlogComment < ActiveRecord::Migration
  def change
    add_column  :cms_posts,   :comments_count,    :integer, :default => 0
    add_column  :cms_posts,   :comments_allowed,  :boolean
    add_column  :cms_blogs,   :comments_allowed,  :boolean
  end
end
