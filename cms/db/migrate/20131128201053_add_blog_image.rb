class AddBlogImage < ActiveRecord::Migration
  def change
    add_column    :cms_blogs, :image, :string
  end
end
