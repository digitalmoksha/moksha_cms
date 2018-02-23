class DmCore::Admin::DashboardController < DmCore::Admin::AdminController

  #------------------------------------------------------------------------------
  def index
    @users = User.all
  end

  # use whatever is passed in, but strip out anything dangerous.  Value will get
  # used as a css selector
  #------------------------------------------------------------------------------
  def change_theme
    cookies[:theme] = {:value => params[:id].replace_non_alphanumeric, :expires => Time.now + 1825.days}
    redirect_back(fallback_location: index)
  end

  private

  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def template_setup
    content_for :content_title, "Dashboard".html_safe
  end
end