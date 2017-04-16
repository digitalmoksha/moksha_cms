class AddBlogImageEmailHeader < ActiveRecord::Migration[4.2]
  def change
    add_column    :cms_blogs, :image_email_header, :string
  end
end
