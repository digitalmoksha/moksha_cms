module DmCore
  module Concerns
    module RegistrationsController
      extend ActiveSupport::Concern
      include DmCore::PermittedParams
      
      included do
        before_action :configure_sign_up_params
        before_action :check_captcha, only: [:create]
      end

      protected

        #------------------------------------------------------------------------------
        def check_captcha
          return unless Rails.application.secrets[:recaptcha_secret_key]
          unless verify_recaptcha(secret_key: Rails.application.secrets[:recaptcha_secret_key])
            self.resource = resource_class.new sign_up_params
            respond_with_navigational(resource) { render :new }
          end 
        end

        # hook into devise to permit our special parameters
        #------------------------------------------------------------------------------
        def configure_sign_up_params
          devise_parameter_sanitizer.for(:sign_up) { |user| devise_sign_up_params(user) }
        end

      module ClassMethods
      end
    end
  end
end
