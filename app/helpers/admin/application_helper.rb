module Admin::ApplicationHelper

  # Switch to the different user
  #------------------------------------------------------------------------------
  def switch_user(user)
    sign_in(:user, user)
  end

end