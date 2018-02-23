module DmLms
  module LessonMenuHelper
    # return the information needed to create a menu link for a lesson
    #------------------------------------------------------------------------------
    def lesson_menu_item(lesson, current_lesson)
      item = {current:    lesson.slug == current_lesson.slug,
              published:  lesson.published?,
              title:      lesson.menutitle,
              allowed:    false}
      if item[:published] || can?(:edit, lesson)
        unless item[:title].blank?
          item[:allowed] = true
        end
      end
      return item
    end

    # return the information needed to create a menu link for a lesson page
    #------------------------------------------------------------------------------
    def lesson_page_menu_item(lesson_page, current_lesson_page)
      item = {current:    lesson_page.slug == current_lesson_page.slug,
              published:  lesson_page.published?,
              title:      lesson_page.menutitle,
              allowed:    false}
      if item[:published] || can?(:edit, lesson_page)
        unless item[:title].blank?
          item[:url] = dm_lms.lesson_page_show_path(lesson_page.lesson.course.slug, lesson_page.lesson.slug, lesson_page.slug)
          item[:allowed] = true
        end
      end
      return item
    end
  end
end
