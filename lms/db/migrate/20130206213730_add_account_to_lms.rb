class AddAccountToLms < ActiveRecord::Migration[4.2]
  def change
    add_column  :lms_courses,                 :account_id, :integer
    add_index   :lms_courses,                 :account_id
    add_column  :lms_lesson_pages,            :account_id, :integer
    add_index   :lms_lesson_pages,            :account_id
    add_column  :lms_lessons,                 :account_id, :integer
    add_index   :lms_lessons,                 :account_id
    add_column  :lms_teachings,               :account_id, :integer
    add_index   :lms_teachings,               :account_id
  end
end
