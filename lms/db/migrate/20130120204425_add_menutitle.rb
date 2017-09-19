class AddMenutitle < ActiveRecord::Migration[4.2]
  def up
    add_column    :lms_course_translations,   :menutitle,     :string
    add_column    :lms_lesson_translations,   :menutitle,     :string
    add_column    :lms_teaching_translations, :menutitle,     :string
    rename_column :lms_lesson_pages,          :content_id,    :item_id
    rename_column :lms_lesson_pages,          :content_type,  :item_type
    add_column    :lms_teaching_translations, :content,       :text    
  end

  def down
    remove_column :lms_course_translations,   :menutitle
    remove_column :lms_lesson_translations,   :menutitle
    remove_column :lms_teaching_translations, :menutitle
    rename_column :lms_lesson_pages,          :item_id,       :content_id
    rename_column :lms_lesson_pages,          :item_type,     :content_type
    remove_column :lms_teaching_translations, :content
  end
end
