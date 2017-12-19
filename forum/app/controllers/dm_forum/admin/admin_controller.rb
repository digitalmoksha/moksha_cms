class DmForum::Admin::AdminController < DmCore::Admin::AdminController
  before_action   :authorize_access

protected

  #------------------------------------------------------------------------------
  def authorize_access
    unless can?(:manage_forums, :all)
      flash[:alert] = "Unauthorized Access!"
      redirect_to current_account.index_path
    end
  end
end
