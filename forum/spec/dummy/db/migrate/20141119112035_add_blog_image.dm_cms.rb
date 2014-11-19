# This migration comes from dm_cms (originally 20131128201053)
class AddBlogImage < ActiveRecord::Migration
  def change
    add_column    :cms_blogs, :image, :string
  end
end
