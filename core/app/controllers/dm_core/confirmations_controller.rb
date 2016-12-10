# common Devise Confirmation controller.  the main app can add methods
# to this class
#------------------------------------------------------------------------------
class DmCore::ConfirmationsController < Devise::RegistrationsController
  include DmCore::Concerns::ConfirmationsController
end
