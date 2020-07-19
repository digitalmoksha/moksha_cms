class DmLms::Admin::CoursesController < DmLms::Admin::AdminController
  include DmLms::PermittedParams

  helper DmLms::ApplicationHelper

  before_action :course_lookup, except: [:index, :new, :create]

  # GET /admin/courses, GET /admin/courses.json
  #------------------------------------------------------------------------------
  def index
    @courses = Course.all.includes(:translations)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @courses }
    end
  end

  # GET /admin/courses/1, GET /admin/courses/1.json
  #------------------------------------------------------------------------------
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @course }
    end
  end

  # GET /admin/courses/new, GET /admin/courses/new.json
  #------------------------------------------------------------------------------
  def new
    @course = Course.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @course }
    end
  end

  # GET /admin/courses/1/edit
  #------------------------------------------------------------------------------
  def edit; end

  # POST /admin/courses, POST /admin/courses.json
  #------------------------------------------------------------------------------
  def create
    @course = Course.new(course_params)

    respond_to do |format|
      if @course.save
        format.html { redirect_to admin_course_url(@course), notice: 'Course was successfully created.' }
        format.json { render json: @course, status: :created, location: @course }
      else
        format.html { render action: "new" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/courses/1, PUT /admin/courses/1.json
  #------------------------------------------------------------------------------
  def update
    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to admin_course_url(@course), notice: 'Course was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/courses/1, DELETE /admin/courses/1.json
  #------------------------------------------------------------------------------
  def destroy
    @course.destroy

    respond_to do |format|
      format.html { redirect_to admin_courses_url }
      format.json { head :no_content }
    end
  end

  #------------------------------------------------------------------------------
  def sort
    @course.update_attribute(:row_order_position, params[:item][:row_order_position])

    #--- this action will be called via ajax
    head :ok
  end

  private

  #------------------------------------------------------------------------------
  def course_lookup
    @course = Course.friendly.find(params[:id])
  end
end
