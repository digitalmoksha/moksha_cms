class DmLms::CoursesController < DmLms::ApplicationController
  before_action :course_lookup, :except => [:index]

  layout 'course_templates/course_list', :only => [:index]

  #------------------------------------------------------------------------------
  def index
    @courses = Course.all.includes(:translations)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @courses }
    end
  end

  # redirect to the first lessons
  #------------------------------------------------------------------------------
  def show
    redirect_to dm_lms.lesson_page_show_path(@course.slug, @course.lessons.first.slug, @course.lessons.first.lesson_pages.first.slug)
  end

  private

  #------------------------------------------------------------------------------
  def course_lookup
    @course = Course.friendly.find(params[:course_slug])
    authorize! :read, @course
  end
end
