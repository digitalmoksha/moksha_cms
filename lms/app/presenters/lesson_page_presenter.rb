class LessonPagePresenter < LmsCommonPresenter
  presents :lesson

  #------------------------------------------------------------------------------
  def icon
    'fa fa-tasks'
  end

  #------------------------------------------------------------------------------
  def next_lesson_page_url
    next_page = model.next(published_only: !is_admin?)
    next_page.nil? ? '' : h.lesson_page_show_url(next_page.lesson.course.slug, next_page.lesson.slug, next_page.slug)
  end

  #------------------------------------------------------------------------------
  def prev_lesson_page_url
    prev_page = model.previous(published_only: !is_admin?)
    prev_page.nil? ? '' : h.lesson_page_show_url(prev_page.lesson.course.slug, prev_page.lesson.slug, prev_page.slug)
  end
end
