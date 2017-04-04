# For managing system wide settings, sites, etc
#------------------------------------------------------------------------------
class DmCore::Admin::SystemController < DmCore::Admin::AdminController
  include DmCore::PermittedParams

  before_filter   :authorize_access

  #------------------------------------------------------------------------------
  def show
    @accounts = Account.unscoped.all.order(:domain)
  end

  #------------------------------------------------------------------------------
  def general
    if put_or_post?
      @account.general_validation = true
      if @account.update_attributes(account_params)
        redirect_to(dm_core.admin_account_general_path, notice: "Account was successfully updated.") and return
      else
        render action: "general"
      end
    end
  end

protected

  #------------------------------------------------------------------------------
  def authorize_access
    unless is_sysadmin?
      flash[:alert] = "Unauthorized Access!"
      redirect_to current_account.index_path 
    end
  end

private

  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def template_setup
    content_for :content_title,     "System Administration"
    content_for :content_subtitle,  "Multi-site Management"
  end

end
