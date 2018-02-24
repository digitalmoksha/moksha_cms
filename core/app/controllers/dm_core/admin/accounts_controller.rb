class DmCore::Admin::AccountsController < DmCore::Admin::AdminController
  include DmCore::PermittedParams

  skip_before_action  :template_setup
  before_action       :authorize_access
  before_action       :account_lookup, except: [:new_account, :create_account]
  before_action       :template_setup

  #------------------------------------------------------------------------------
  def show
    redirect_to dm_core.admin_account_general_path(@account)
  end

  #------------------------------------------------------------------------------
  def new_account
    redirect_to dm_core.admin_account_general_path(current_account) unless is_sysadmin?
    @account = Account.new
    render action: :general
  end

  #------------------------------------------------------------------------------
  def create_account
    redirect_to dm_core.admin_account_general_path(current_account) unless is_sysadmin?

    @account = Account.new(account_params)
    @account.general_validation = true
    if @account.save
      org_account = Account.current
      Account.current = @account
      CmsPage.create_default_site
      Account.current = org_account
      redirect_to dm_core.admin_account_general_path(@account), notice: 'New Account/Site was successfully created.'
    else
      render action: :general
    end
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

  # PUT /admin/account or PUT /admin/account/.json
  #------------------------------------------------------------------------------
  def email
    if put_or_post?
      @account.email_validation = true
      params[:account].delete(:preferred_smtp_password) if params[:account][:preferred_smtp_password].blank?
      if @account.update_attributes(account_params)
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
      params[:account].delete(:preferred_sofort_project_password) if params[:account][:preferred_sofort_project_password].blank?
      params[:account].delete(:preferred_sofort_notification_password) if params[:account][:preferred_sofort_notification_password].blank?
      if @account.update_attributes(account_params)
        redirect_to(dm_core.admin_account_analytics_path, notice: "Account was successfully updated.") and return
      else
        render action: "analytics"
      end
    end
  end

  #------------------------------------------------------------------------------
  def metadata
    if put_or_post?
      @account.metadata_validation = true
      if @account.update_attributes(account_params)
        redirect_to(dm_core.admin_account_metadata_path, notice: "Account was successfully updated.") and return
      else
        render action: "metadata"
      end
    end
  end

  #------------------------------------------------------------------------------
  def media
    if put_or_post?
      @account.media_validation = true
      if @account.update_attributes(account_params)
        redirect_to(dm_core.admin_account_media_path, notice: "Account was successfully updated.") and return
      else
        render action: "media"
      end
    end
  end

  protected

  #------------------------------------------------------------------------------
  def authorize_access
    unless is_admin?
      flash[:alert] = "Unauthorized Access!"
      redirect_to current_account.index_path
    end
  end

  private

  #------------------------------------------------------------------------------
  def account_lookup
    @account = Account.find(params[:id]) if is_sysadmin? && params[:id]
    @account ||= current_account
  end

  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def template_setup
    content_for :content_title,     @account.nil? ? 'Create a New Site' : @account.domain
    content_for :content_subtitle,  "Site Configuration"
  end
end
