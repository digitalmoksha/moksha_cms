class DmCore::Admin::AccountsController < DmCore::Admin::AdminController

  before_filter   :account_lookup

  #------------------------------------------------------------------------------
  def show
    redirect_to dm_core.admin_account_general_path
  end

  #------------------------------------------------------------------------------
  def general
    if put_or_post?
      @account.general_validation = true
      if @account.update_attributes(params[:account])
        redirect_to(dm_core.admin_account_general_path, notice: "Account was successfully updated.") and return
      else
        render action: "general"
      end
    end
  end

  # PUT /admin/account or PUT /admin/account/.json
  #------------------------------------------------------------------------------
  def email
    if put_or_post?
      @account.email_validation = true
      params[:account].delete(:preferred_smtp_password) if params[:account][:preferred_smtp_password].blank?
      if @account.update_attributes(params[:account])
        redirect_to(dm_core.admin_account_email_path, notice: "Account was successfully updated.") and return
      else
        render action: "email"
      end
    end
  end

  #------------------------------------------------------------------------------
  def analytics
    if put_or_post?
      @account.analytics_validation = true
      if @account.update_attributes(params[:account])
        redirect_to(dm_core.admin_account_analytics_path, notice: "Account was successfully updated.") and return
      else
        render action: "analytics"
      end
    end
  end

private

  #------------------------------------------------------------------------------
  def account_lookup
    @account = current_account
  end

  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def template_setup
    content_for :content_title, "#{icons('font-user')} Account Management".html_safe
  end

end
