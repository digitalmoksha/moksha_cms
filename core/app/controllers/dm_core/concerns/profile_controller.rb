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
          if @user_profile.update_attributes(user_profile_params)
            flash.now[:notice] = I18n.t('core.profile_profile_updated')
          end
        end
      end

      module ClassMethods
      end
    end
  end
end
