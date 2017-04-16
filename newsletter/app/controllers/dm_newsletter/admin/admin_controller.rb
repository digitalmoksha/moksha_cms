class DmNewsletter::Admin::AdminController < DmCore::Admin::AdminController
  include DmNewsletter::NewslettersHelper
  helper  'dm_newsletter/newsletters'

  before_action   :authorize_access
  
protected

  #------------------------------------------------------------------------------
  def authorize_access
    unless can?(:manage_newsletters, :all)
      flash[:alert] = "Unauthorized Access!"
      redirect_to current_account.index_path 
    end
  end
end
