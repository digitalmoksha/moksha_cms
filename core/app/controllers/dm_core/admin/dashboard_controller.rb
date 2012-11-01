class DmCore::Admin::DashboardController < DmCore::Admin::AdminController

  #------------------------------------------------------------------------------
  def index
    @users = User.all
  end

  #------------------------------------------------------------------------------
  def update_site_assets
    @results = `svn up #{Rails.root}/public/site_assets`
  end
  
private
  
  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def template_setup
    content_for :content_title, '<span class="icon-screen"></span>Dashboard'.html_safe
  end
end