class AddPublicPrivate < ActiveRecord::Migration[5.0]
  def change
    add_column  :lms_courses, :is_public, :boolean, default: false
    add_column  :lms_courses, :requires_login, :boolean, default: false
    add_column  :lms_courses, :requires_subscription, :boolean, default: false
    add_column  :lms_courses, :comments_allowed, :boolean
  end
end
