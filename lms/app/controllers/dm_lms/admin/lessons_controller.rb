class DmLms::Admin::LessonsController < DmLms::Admin::AdminController
  include DmLms::PermittedParams

  before_action   :course_lookup, only: [:new, :create]
  before_action   :lesson_lookup, except: [:new, :create]

  # GET /admin/lessons/1, GET /admin/lessons/1.json
  #------------------------------------------------------------------------------
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lesson }
    end
  end

  # GET /admin/lessons/new, GET /admin/lessons/new.json
  #------------------------------------------------------------------------------
  def new
    @lesson = @course.lessons.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @lesson }
    end
  end

  # GET /admin/lessons/1/edit
  #------------------------------------------------------------------------------
  def edit; end

  # POST /admin/lessons, POST /admin/lessons.json
  #------------------------------------------------------------------------------
  def create
    @lesson = @course.lessons.new(lesson_params)

    respond_to do |format|
      if @lesson.save
        format.html { redirect_to admin_lesson_url(@lesson), notice: 'Lesson was successfully created.' }
        format.json { render json: @lesson, status: :created, location: @lesson }
      else
        format.html { render action: "new" }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/lessons/1, PUT /admin/lessons/1.json
  #------------------------------------------------------------------------------
  def update
    respond_to do |format|
      if @lesson.update(lesson_params)
        format.html { redirect_to admin_lesson_url(@lesson), notice: 'Lesson was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/lessons/1, DELETE /admin/lessons/1.json
  #------------------------------------------------------------------------------
  def destroy
    @lesson.destroy

    respond_to do |format|
      format.html { redirect_to admin_course_url(@course), notice: 'Lesson was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  #------------------------------------------------------------------------------
  def sort
    @lesson.update_attribute(:row_order_position, params[:item][:row_order_position])

    #--- this action will be called via ajax
    head :ok
  end

  private

  #------------------------------------------------------------------------------
  def course_lookup
    @course = Course.friendly.find(params[:course_id])
  end

  #------------------------------------------------------------------------------
  def lesson_lookup
    @lesson = Lesson.friendly.find(params[:id])
    @course = @lesson.course
  end
end
