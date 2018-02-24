#------------------------------------------------------------------------------
class DmCore::Admin::SetupController < ActionController::Base
  include DmCore::PermittedParams

  layout 'admin_theme/admin_basic'

  include DmCore::ApplicationHelper
  include DmCore::AccountHelper
  include DmCore::Admin::ApplicationHelper
  include AdminTheme::ThemeHelper

  helper  DmAdmin::ApplicationHelper
  helper  AdminTheme::ThemeHelper

  # only a prsitine system can perform this setup
  #------------------------------------------------------------------------------
  def initial_setup
    redirect_to main_app.root_url unless no_sysadmins? && Account.count == 0
  end

  #------------------------------------------------------------------------------
  def step1
    redirect_to main_app.root_url unless no_sysadmins? && Account.count == 0
    if put_or_post?
      @account = Account.new(params.require(:account).permit!)
      @account.general_validation = true
      if @account.save
        redirect_to dm_core.admin_setup_step2_path
      end
      Role.unscoped.create!(name: 'sysadmin', account_id: 0)
    else
      @account = Account.new
    end
  end

  #------------------------------------------------------------------------------
  def step2
    redirect_to main_app.root_url unless no_sysadmins? && Account.count == 1
    @account = Account.first
    Account.current = @account
    if put_or_post?
      @user = User.new(params.require(:user).permit!)
      @user.user_profile.public_name = 'admin'
      @user.skip_confirmation!
      if @user.save
        @user.add_role :admin
        sysadmin = Role.unscoped.where(name: 'sysadmin').first
        @user.roles << sysadmin if User.all.count == 1 && sysadmin
        @user.save!
        switch_user(@user)
        redirect_to admin_account_general_path(id: @account)
      end
    else
      @user = User.new
    end
  end

  protected

  def no_sysadmins?
    sysadmin_role = Role.unscoped.find_by_name('sysadmin')
    sysadmin_role.nil? || sysadmin_role.users.empty?
  end
end
