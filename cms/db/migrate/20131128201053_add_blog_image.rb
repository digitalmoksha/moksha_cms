class AddBlogImage < ActiveRecord::Migration[4.2]
  def change
    add_column    :cms_blogs, :image, :string
  end
end
