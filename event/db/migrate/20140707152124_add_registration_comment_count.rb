class AddRegistrationCommentCount < ActiveRecord::Migration[4.2]
  def change
    add_column    :ems_registrations,   :comments_count,  :integer
  end
end
