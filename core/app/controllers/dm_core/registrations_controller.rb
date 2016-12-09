# common Devise Registration controller.  the main app can add methods
# to this class
#------------------------------------------------------------------------------
class DmCore::RegistrationsController < Devise::RegistrationsController
  include DmCore::Concerns::RegistrationsController
end
