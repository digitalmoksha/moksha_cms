# Subclass from main ApplicationController, which will subclass from DmCore
#------------------------------------------------------------------------------
class DmCore::ProfileController < ::ApplicationController
  include DmCore::Concerns::ProfileController

  layout 'layouts/general_templates/user_profile'

end
