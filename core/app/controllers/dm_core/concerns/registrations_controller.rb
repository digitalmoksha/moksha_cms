module DmCore
  module Concerns
    module RegistrationsController
      extend ActiveSupport::Concern
      include DmCore::PermittedParams

      included do
        before_action :configure_permitted_parameters, if: :devise_controller?
        before_action :check_captcha, only: [:create]
      end

      protected

      #------------------------------------------------------------------------------
      def check_captcha
        return unless Rails.application.secrets[:recaptcha_secret_key]

        unless verify_recaptcha(secret_key: Rails.application.secrets[:recaptcha_secret_key])
          self.resource = resource_class.new sign_up_params
          flash[:error] = 'There was an error with the reCAPTCHA. Please solve the reCAPTCHA again.'
          flash.delete :recaptcha_error

          respond_with_navigational(resource) { render :new }
        end
      end

      # hook into devise to permit our special parameters
      #------------------------------------------------------------------------------
      def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up) do |user_params|
          devise_sign_up_params(user_params)
        end
      end

      module ClassMethods
      end
    end
  end
end
