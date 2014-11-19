# This migration comes from dm_cms (originally 20140601151631)
class AddBlogImageEmailHeader < ActiveRecord::Migration
  def change
    add_column    :cms_blogs, :image_email_header, :string
  end
end
