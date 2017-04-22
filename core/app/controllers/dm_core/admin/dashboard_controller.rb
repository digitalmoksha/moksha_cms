class DmCore::Admin::DashboardController < DmCore::Admin::AdminController

  #------------------------------------------------------------------------------
  def index
    @users = User.all
  end

  #------------------------------------------------------------------------------
  def update_site_assets
    if is_sysadmin?
      #--- svn up can't follow a symlink, so resolve it first
      path = File.readlink("#{Rails.root}/public/#{account_site_assets(false)}")
      @results = "Updating 'site_assets'...\r\n"
      @results += `svn up #{path}`
      if File.exists?("#{Account.current.theme_path}/protected_assets")
        path = File.join(File.readlink("#{Account.current.theme_path}"), "protected_assets")
        @results += "\nUpdating 'protected_assets'...\r\n"
        @results += `svn up #{path}`
      end
    end
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