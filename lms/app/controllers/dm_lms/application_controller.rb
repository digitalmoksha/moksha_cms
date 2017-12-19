# Subclass from main ApplicationController, which will subclass from DmCore
#------------------------------------------------------------------------------
class DmLms::ApplicationController < ::ApplicationController

  include       ApplicationHelper
  helper        DmLms::ApplicationHelper
  helper        DmLms::LessonMenuHelper
  layout        'course_templates/default_with_sidebar'
  before_action :authenticate_user!

end
