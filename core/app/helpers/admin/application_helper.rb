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

  # http://stackoverflow.com/questions/8552763/best-way-to-highlight-current-page-in-rails-3-apply-a-css-class-to-links-con
  #------------------------------------------------------------------------------
  def admin_path_active_class?(*paths)
    active = false
    # paths.each { |path| active ||= current_page?(path) }
    paths.each { |path| active ||= request.url.include?(path) }
    active ? 'active' : nil
  end
  
end