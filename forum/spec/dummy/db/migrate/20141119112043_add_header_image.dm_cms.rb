# This migration comes from dm_cms (originally 20141004154725)
class AddHeaderImage < ActiveRecord::Migration
  def change
    rename_column     :cms_pages, :image, :featured_image
    add_column        :cms_pages, :header_image, :string

    rename_column     :cms_blogs, :image, :header_image
    rename_column     :cms_posts, :image, :featured_image
  end
end
