class AddForumOwner < ActiveRecord::Migration[4.2]
  def change
    add_column    :fms_forums, :owner_id,    :integer
    add_column    :fms_forums, :owner_type,  :string
  end
end
