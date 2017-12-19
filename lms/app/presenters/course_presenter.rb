# Define presentation-specific methods here. Helpers are accessed through
# `helpers` (aka `h`).
#------------------------------------------------------------------------------
class CoursePresenter < LmsCommonPresenter
  presents :course
  #delegate :something, to: :course

  #------------------------------------------------------------------------------
  def label_published
    if course.teaser_only?
      h.colored_label('Teaser', :info)
    else
      course.published? ? h.colored_label('Published', :success) : h.colored_label('Draft')
    end
  end

  #------------------------------------------------------------------------------
  def icon
    'fa fa-book'
  end

end