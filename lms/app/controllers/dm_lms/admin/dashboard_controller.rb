class DmLms::Admin::DashboardController < DmLms::Admin::AdminController

  #------------------------------------------------------------------------------
  def widget_lesson_comments
    @comment_day  = params[:comment_day].to_i
    @comments     = Comment.where(commentable_type: 'LessonPage', created_at: (Date.today - @comment_day.day).midnight..(Date.today - (@comment_day - 1).day).midnight).order('created_at DESC')
    @url_today    = dm_lms.admin_widget_lesson_comments_path(comment_day: 0)
    @url_refresh  = dm_lms.admin_widget_lesson_comments_path(comment_day: @comment_day)
    @url_prev     = dm_lms.admin_widget_lesson_comments_path(comment_day: @comment_day + 1)
    @url_next     = dm_lms.admin_widget_lesson_comments_path(comment_day: @comment_day - 1)
    respond_to do |format|
      format.html {render layout: false}
      format.js
    end
  end

end