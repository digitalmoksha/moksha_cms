class DmCore::Admin::DashboardController < DmCore::Admin::AdminController

  #------------------------------------------------------------------------------
  def index
    @users = User.all
  end

  #------------------------------------------------------------------------------
  def update_site_assets
    @results = "Updating 'site_assets'...\r\n"
    @results += `svn up #{Rails.root}/public/site_assets`
    if File.exists?("#{Rails.root}/protected_assets")
      @results += "\nUpdating 'protected_assets'...\r\n"
      @results += `svn up #{Rails.root}/protected_assets`
    end
  end
  
  # use whatever is passed in, but strip out anything dangerous.  Value will get
  # used as a css selector
  #------------------------------------------------------------------------------
  def change_theme
    cookies[:theme] = {:value => params[:id].replace_non_alphanumeric, :expires => Time.now + 1825.days}
    redirect_to :back
  end

private
  
  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def template_setup
    content_for :content_title, "#{icons('font-dashboard')} Dashboard".html_safe
  end
end