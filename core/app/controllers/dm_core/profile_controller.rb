# Subclass from main ApplicationController, which will subclass from DmCore
#------------------------------------------------------------------------------
class DmCore::ProfileController < ::ApplicationController

  layout 'layouts/general_templates/user_profile'
  
  before_filter   :authenticate_user!
  
  #------------------------------------------------------------------------------
  def account
    @user = current_user
    if put_or_post?
      @user = User.find(current_user.id)
      if @user.update_with_password(params[:user])
        #--- Sign in the user bypassing validation in case his password changed
        sign_in @user, :bypass => true
        if params[:user][:email] != @user.email
          flash.now[:notice] = I18n.t('core.profile_email_confirmation')
        else
          flash.now[:notice] = I18n.t('core.profile_password_updated')
        end
      end
    end
  end
  
  #------------------------------------------------------------------------------
  def details
    @user_profile = current_user.user_profile
    if put_or_post?
      if @user_profile.update_attributes(params[:user_profile])
        flash.now[:notice] = I18n.t('core.profile_profile_updated')
      end
    end
  end

end
