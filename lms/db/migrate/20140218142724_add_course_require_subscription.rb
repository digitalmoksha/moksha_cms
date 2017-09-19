class AddCourseRequireSubscription < ActiveRecord::Migration[4.2]
  def change
    add_column  :lms_courses, :require_subscription, :boolean, default: true
  end
end
