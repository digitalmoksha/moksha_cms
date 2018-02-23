class DmLms::Admin::TeachingsController < DmLms::Admin::AdminController
  include DmLms::PermittedParams

  before_action   :lesson_lookup,       :only =>    [:index, :new, :create]
  before_action   :teaching_lookup,     :except =>  [:index, :new, :create]

  # GET /admin/teachings/new, GET /admin/teachings/new.json
  #------------------------------------------------------------------------------
  def new
    @lesson_page  = LessonPage.new
    @teaching     = Teaching.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @teaching }
    end
  end

  # GET /admin/teachings/1/edit
  #------------------------------------------------------------------------------
  def edit
  end

  # POST /admin/teachings, POST /admin/teachings.json
  #------------------------------------------------------------------------------
  def create
    @lesson_page  = @lesson.lesson_pages.new(teaching_params.delete(:lesson_page))
    @teaching     = Teaching.new(params[:teaching])

    Teaching.transaction do
      respond_to do |format|
        @lesson_page.item = @teaching  # can't check validity without doing this because of title delegation
        if (@teaching.valid? && @lesson_page.valid?) && @teaching.save
          @teaching.lesson_page = @lesson_page   # this automatically saves the lesson
          format.html { redirect_to edit_admin_teaching_url(@teaching), notice: 'Teaching was successfully created.' }
          format.json { render json: @teaching, status: :created, location: @teaching }
        else
          format.html { render action: "new" }
          format.json { render json: @teaching.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PUT /admin/teachings/1, PUT /admin/teachings/1.json
  #------------------------------------------------------------------------------
  def update
    params[:lesson_page] = teaching_params.delete(:lesson_page)
    Teaching.transaction do
      respond_to do |format|
        if @lesson_page.update_attributes(params[:lesson_page]) && @teaching.update_attributes(params[:teaching])
          format.html { redirect_to edit_admin_teaching_url(@teaching), notice: 'Teaching was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @teaching.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  private

  #------------------------------------------------------------------------------
  def lesson_lookup
    @lesson = Lesson.friendly.find(params[:lesson_id])
  end

  #------------------------------------------------------------------------------
  def teaching_lookup
    @teaching     = Teaching.find(params[:id])
    @lesson_page  = @teaching.lesson_page
    @lesson       = @lesson_page.lesson
  end
end
