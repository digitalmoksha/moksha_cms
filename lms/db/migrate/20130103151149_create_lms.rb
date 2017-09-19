class CreateLms < ActiveRecord::Migration[4.2]
  def up
    create_table :lms_courses do |t|
      t.integer       :teacher_id
      t.string        :slug,            :limit => 50, :default => "", :null => false
      t.boolean       :published
      t.integer       :row_order
      t.timestamps null: true
    end
    add_index :lms_courses, ["slug"], :name => "courseslug_key"
    
    create_table :lms_course_translations do |t|
      t.integer       :course_id
      t.string        :locale
      t.string        :title
      t.text          :description
      t.timestamps null: true
    end
    add_index :lms_course_translations, ["course_id"], :name => "course_id_index"
    
    create_table :lms_lessons do |t|
      t.integer       :course_id
      t.string        :slug,            :limit => 50, :default => "", :null => false
      t.boolean       :published
      t.integer       :row_order
      t.timestamps null: true
    end
    add_index :lms_lessons, ["slug"], :name => "lessonslug_key"

    create_table :lms_lesson_translations do |t|
      t.integer       :lesson_id
      t.string        :locale
      t.string        :title
      t.text          :description
      t.timestamps null: true
    end
    add_index :lms_lesson_translations, ["lesson_id"], :name => "lesson_id_index"

    create_table :lms_lesson_pages do |t|
      t.integer       :lesson_id
      t.string        :slug,            :limit => 50, :default => "", :null => false
      t.boolean       :published
      t.integer       :content_id
      t.string        :content_type
      t.integer       :row_order
      t.timestamps null: true
    end
    add_index :lms_lesson_pages, ["slug"], :name => "lessonpageslug_key"

    create_table :lms_teachings do |t|
      t.timestamps null: true
    end

    create_table :lms_teaching_translations do |t|
      t.integer       :teaching_id
      t.string        :locale
      t.string        :title
      t.timestamps null: true
    end
    add_index :lms_teaching_translations, ["teaching_id"], :name => "teaching_id_index"

  end

  def down
    drop_table  :lms_courses
    drop_table  :lms_course_translations
    drop_table  :lms_lessons
    drop_table  :lms_lesson_translations
    drop_table  :lms_lesson_pages
    drop_table  :lms_teachings
    drop_table  :lms_teaching_translations
  end
end
