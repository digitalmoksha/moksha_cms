class DmLms::Admin::LessonPagesController < DmLms::Admin::AdminController
  include DmLms::PermittedParams

  before_action   :lesson_page_lookup

  # GET /admin/lessons, GET /admin/lessons.json
  # Unused: happens through the lesson object
  #------------------------------------------------------------------------------

  # GET /admin/lesson_pages/1, GET /admin/lesson_pages/1.json
  # Unused: happens through the quiz/teaching object
  #------------------------------------------------------------------------------

  # GET /admin/lesson_pages/new, GET /admin/lesson_pages/new.json
  # Unused: happens through the quiz/teaching object
  #------------------------------------------------------------------------------

  # GET /admin/lesson_pages/1/edit
  # Unused: happens through the quiz/teaching object
  #------------------------------------------------------------------------------

  # POST /admin/lesson_pages, POST /admin/lesson_pages.json
  # Unused: happens through the quiz/teaching object
  #------------------------------------------------------------------------------

  # PUT /admin/lesson_pages/1, PUT /admin/lesson_pages/1.json
  # Unused: updates happen through the quiz/teaching object
  #------------------------------------------------------------------------------

  # DELETE /admin/lesson_pages/1, DELETE /admin/lesson_pages/1.json
  #------------------------------------------------------------------------------
  def destroy
    # --- destroy the lesson page destroys the quiz/teaching
    @lesson_page.destroy

    respond_to do |format|
      format.html { redirect_to admin_lesson_url(@lesson), notice: 'Lesson was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  #------------------------------------------------------------------------------
  def sort
    @lesson_page.update_attribute(:row_order_position, params[:item][:row_order_position])

    #--- this action will be called via ajax
    head :ok
  end

private

  #------------------------------------------------------------------------------
  def lesson_page_lookup
    @lesson_page = LessonPage.friendly.find(params[:id])
    @lesson = @lesson_page.lesson
  end

  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def template_setup
    content_for :content_title, 'Lesson Pages'
  end

end
