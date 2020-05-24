module DmCore
  module Concerns
    module ProfileController
      extend ActiveSupport::Concern
      include DmCore::PermittedParams

      included do
        before_action :authenticate_user!
      end

      #------------------------------------------------------------------------------
      def account
        @user = current_user
        if put_or_post?
          if @user.update_with_password(user_params)
            #--- Sign in the user bypassing validation in case his password changed
            bypass_sign_in @user
            flash.now[:notice] = if params[:user][:email] != @user.email
                                   I18n.t('core.profile_email_confirmation')
                                 else
                                   I18n.t('core.profile_password_updated')
                                 end
          end
        end
      end

      #------------------------------------------------------------------------------
      def details
        @user_profile = current_user.user_profile
        if put_or_post?
          flash.now[:notice] = I18n.t('core.profile_profile_updated') if @user_profile.update_attributes(user_profile_params)
        end
      end

      module ClassMethods
      end
    end
  end
end
