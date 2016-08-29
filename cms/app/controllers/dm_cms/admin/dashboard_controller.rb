class DmCms::Admin::DashboardController < DmCms::Admin::AdminController
  
  #------------------------------------------------------------------------------
  def widget_blog_comments
    @comment_day = params[:comment_day].to_i
    respond_to do |format|
      format.html
      format.js
    end
  end

end