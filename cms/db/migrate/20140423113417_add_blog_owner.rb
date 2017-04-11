class AddBlogOwner < ActiveRecord::Migration[4.2]
  def change
    add_column    :cms_blogs, :owner_id,    :integer
    add_column    :cms_blogs, :owner_type,  :string
  end
end
