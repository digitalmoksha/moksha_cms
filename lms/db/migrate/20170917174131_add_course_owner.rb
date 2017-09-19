class AddCourseOwner < ActiveRecord::Migration[5.0]
  def change
    add_column    :lms_courses, :owner_id,    :integer
    add_column    :lms_courses, :owner_type,  :string
  end
end
