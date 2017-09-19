class IncreaseSlugLength < ActiveRecord::Migration[5.0]
  def up
    # remove any string limits
    change_column :lms_courses, :slug, :string, limit: 191
    change_column :lms_lesson_pages, :slug, :string, limit: 191
    change_column :lms_lessons, :slug, :string, limit: 191
  end

  def down
    change_column :lms_courses, :slug, :string, limit: 50
    change_column :lms_lesson_pages, :slug, :string, limit: 50
    change_column :lms_lessons, :slug, :string, limit: 50
  end
end
