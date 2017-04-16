class AddForumCategory < ActiveRecord::Migration[4.2]

  def change
    add_column    :fms_forums, :forum_category_id, :integer
  end

end
