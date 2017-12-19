module DmCore
  module Concerns
    module ConfirmationsController
      extend ActiveSupport::Concern
      include DmCore::PermittedParams

      included do
      end

      protected

        # Example
        # The path used after confirmation.
        #------------------------------------------------------------------------------
        # def after_confirmation_path_for(resource_name, resource)
        #   index_url
        # end
        #------------------------------------------------------------------------------

      module ClassMethods
      end
    end
  end
end
