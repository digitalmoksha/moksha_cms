class AddCommentCount < ActiveRecord::Migration[4.2]
  def change
    add_column    :lms_lesson_pages,  :comments_count, :integer, :default => 0
  end
end
