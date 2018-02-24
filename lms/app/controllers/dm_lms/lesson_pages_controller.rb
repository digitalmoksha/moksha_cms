class DmLms::LessonPagesController < DmLms::ApplicationController
  include DmCore::RenderHelper

  before_action :content_lookup, except: [:ajax_add_comment, :ajax_delete_comment]

  # GET /learn/:course_slug/:lesson_slug/:content_slug
  # GET /learn/:course_slug/:lesson_slug/:content_slug.json
  #------------------------------------------------------------------------------
  def show
    redirect_to dm_cms.showpage_url(slug: 'missing') and return if @lesson_page.nil?
    redirect_to main_app.index_url and return if !@lesson_page.published? && !current_user.is_admin?
    @comments = @lesson_page.comments.paginate page: page_number
    case @lesson_page.item.class.to_s
    when 'Teaching'
      show_teaching
    when 'Quiz'
      show_quiz
    end
  end

  #------------------------------------------------------------------------------
  def show_teaching
    render 'show_teaching'
  end

  #------------------------------------------------------------------------------
  def show_quiz
    @quiz             = @lesson_page.item
    @practice_set     = @quiz.practice_set
    if @practice_set
      @practice_history = PracticeHistory.where(user_id: current_user, practice_set_id: @practice_set).first_or_create

      #--- if all the cards are answered, show completed msg, and give chance to retry
      if @practice_history.all_cards_answered_once? && params[:retry] != '1'
        @quiz_completed = true
      else
        #--- reset the history, start fresh
        @practice_history.reset_history
      end

      @study_items = @practice_history.study_items.shuffle
      render 'show_quiz', layout: 'course_templates/quiz_with_sidebar'
    else
      flash.now[:error] = 'A practice set needs to be specified'
      head :ok
    end
  end

  #------------------------------------------------------------------------------
  def ajax_add_comment
    @lesson_page = LessonPage.friendly.find(params[:lesson_page_id])
    # @lesson_page.comments.create(:body => params[:body], :user_id => current_user.id)
    @lesson_page.comments.create(body: params[:comment][:body], user_id: current_user.id) if current_user && !params[:comment][:body].blank?

    #--- give the object a chance to do something if necessary
    # @lesson_page.comment_notify(@comment) if @lesson_page.respond_to?(:comment_notify)

    respond_to do |format|
      format.html { redirect_back(fallback_location: lesson_page_url(@lesson_page)) }
      format.json { head :ok }
    end
  end

  #------------------------------------------------------------------------------
  def ajax_delete_comment
    comment = Comment.destroy(params[:id])
    lesson_page = comment.commentable
    respond_to do |format|
      format.html { redirect_back(fallback_location: lesson_page_url(lesson_page)) }
      format.json { head :ok }
    end
  end

  private

  #------------------------------------------------------------------------------
  def content_lookup
    @course = Course.friendly.find(params[:course_slug])
    authorize! :read, @course
    @lesson = @course.lessons.friendly.find(params[:lesson_slug])
    @lesson_page = @lesson.try(:lesson_pages).try(:find_by_slug, params[:content_slug])
  end
end
