# Extends the User model with hooks for the Event engine
#------------------------------------------------------------------------------
module DmEvent
  module Concerns
    module UserProfile
      extend ActiveSupport::Concern

      included do
        has_many   :registrations
      end

      #------------------------------------------------------------------------------
      module ClassMethods
      end

    end
  end
end
