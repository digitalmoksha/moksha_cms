class AddRegistrationCommentCount < ActiveRecord::Migration
  def change
    add_column    :ems_registrations,   :comments_count,  :integer
  end
end
