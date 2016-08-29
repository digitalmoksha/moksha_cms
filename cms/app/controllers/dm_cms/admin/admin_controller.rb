class DmCms::Admin::AdminController  < DmCore::Admin::AdminController
  before_filter   :authorize_access
  
protected

  #------------------------------------------------------------------------------
  def authorize_access
    unless can?(:manage_content, :all)
      flash[:alert] = "Unauthorized Access!"
      redirect_to current_account.index_path 
    end
  end

end