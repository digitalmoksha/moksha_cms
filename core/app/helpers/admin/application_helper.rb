module Admin::ApplicationHelper

  # Switch to the different user
  #------------------------------------------------------------------------------
  def switch_user(user)
    sign_in(:user, user)
  end

  #------------------------------------------------------------------------------
  def is_current_controller(controller_name)
    controller.controller_name == controller_name
  end

end