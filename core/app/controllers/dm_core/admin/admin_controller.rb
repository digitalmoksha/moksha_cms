# This controller is a base class for all other admin controllers
# scope_current_account gets called through the eventual inheritacne of DmCore::ApplicationController
#------------------------------------------------------------------------------
class DmCore::Admin::AdminController < ApplicationController

  
  before_filter :authenticate_admin_user!
  before_filter :template_setup

  layout 'admin_theme/admin'
  
  include DmCore::ApplicationHelper
  include DmCore::AccountHelper
  include Admin::ApplicationHelper
  include AdminTheme::ThemeHelper

  helper  DmAdmin::ApplicationHelper
  helper  AdminTheme::ThemeHelper

  # Make sure some type of administrative user is logged in
  #------------------------------------------------------------------------------
  def authenticate_admin_user!
    authenticate_user! 
    unless can?(:access_admin, :all)
      flash[:alert] = "Unauthorized Access!"
      redirect_to current_account.index_path 
    end
  end  

private

  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def template_setup
    # to be overridden by other controllers
  end

end