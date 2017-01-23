# main ApplicationController will subclass from DmCore::ApplicationController
#------------------------------------------------------------------------------
class DmCore::ApplicationController < ActionController::Base
  include DmCore::PermittedParams
  
  before_filter   :log_additional_data
  # before_filter   :record_activity
  before_filter   :check_site_assets
  before_filter   :site_enabled?, :unless => :devise_controller?
  before_filter   :set_mailer_url_options
  before_filter   :update_user
  before_filter   :store_location
  before_filter   :set_cache_buster

  prepend_before_filter   :ssl_redirect
  prepend_before_filter   :theme_resolver
  prepend_before_filter   :set_locale
  prepend_around_filter   :scope_current_account

  add_flash_types :warning, :error, :info

  include DmCore::AccountHelper

  #------------------------------------------------------------------------------
  def index
    redirect_to "/#{current_account.preferred_default_locale}/index", :status => :moved_permanently
  end

protected

  # Nov 27, 2013: There seems to be a nasty Safari 7 bug (and in iOS7).  If a 304 is returned,
  # an empty page can be cached, resulting in a blank page.
  # http://tech.vg.no/2013/10/02/ios7-bug-shows-white-page-when-getting-304-not-modified-from-server/
  # So set headers so that this content will not be cahced, until there is a fix
  # http://stackoverflow.com/questions/711418/how-to-prevent-browser-page-caching-in-rails
  # http://stackoverflow.com/questions/20154740/rails-view-turning-complete-white-after-refreshed-or-visited-several-times
  #------------------------------------------------------------------------------
  def set_cache_buster
    if !request.user_agent.blank? && !request.user_agent.scan(/Safari/).empty? && request.user_agent.scan(/Chrome/).empty? && Rails.env.development?
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"]        = "no-cache"
      response.headers["Expires"]       = "Fri, 01 Jan 1990 00:00:00 GMT"
    end
  end

  # Store last url as long as it isn't a /users path
  # Call from a before_filter - this ensures that if you're coming to a page
  # from an email link, the url gets saved before getting redirected to the login
  #------------------------------------------------------------------------------
  def store_location
    if params[:redirect_to].present?
      store_location_for(:user, params[:redirect_to])    
    end

    # note: don't store the previous url on each call.  this led to an issue where
    # missing asset might get run through this code, causing the user to be redirected
    # to the missing asset during a login
    # session[:previous_url] = request.url if request.url != new_user_session_url
  end

  # override Devise method, on login go to previous url if possible
  #------------------------------------------------------------------------------
  def after_sign_in_path_for(resource)
    stored = stored_location_for(resource)  # this also delete the cookie
    if stored
      stored
    elsif false
      # if there is a welcome page set
    elsif request.referer && request.referer != new_user_session_url
      request.referer
    else
      root_path
    end
  end

  # - if site is not enabled, only allow a logged in Admin user to access pages
  # otherwise, redirect to the 'coming_soon' page
  # - if site is under maintenance, only allow a logged in Admin user to access pages
  # otherwise, redirect to the 'maintenance' page
  #------------------------------------------------------------------------------
  def site_enabled?
    unless current_account.site_enabled? || request.params['slug'] == 'coming_soon'
      unless (user_signed_in? && (current_user.is_admin? || current_user.has_role?(:beta)))
        redirect_to "/#{current_account.preferred_default_locale}/coming_soon"
        return false
      end
    end

    if current_account.site_maintenance?
      unless (user_signed_in? && (current_user.is_admin? || current_user.has_role?(:beta)))
        render text: '', layout: 'dm_core/maintenance'
        return false
      end
    end
  end  

  #------------------------------------------------------------------------------
  def ssl_redirect
    if Rails.env.production? && current_account.ssl_enabled?
      if request.ssl? && !use_ssl? || !request.ssl? && use_ssl?
        protocol = request.ssl? ? "http" : "https"
        redirect_to({protocol: "#{protocol}://"}.merge(params), :flash => flash)
      end
    end
  end

  # override in other controllers
  #------------------------------------------------------------------------------
  def use_ssl?
    true # user_signed_in? (but would need to ensure Devise runs under ssl)
  end
  
  # Choose the theme based on the account prefix in the Account
  #------------------------------------------------------------------------------
  def theme_resolver
    theme(current_account.account_prefix) if DmCore.config.enable_themes
  end

  #------------------------------------------------------------------------------
  def set_mailer_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  # #------------------------------------------------------------------------------
  # def record_activity
  #   if Rails.env.production?
  #     activity = Activity.new
  # 
  #     #--- who is doing the activity?
  #     activity.session_id  = session['session_id'] unless session.nil?
  #     activity.user_id     = current_user.id unless current_user.nil?
  #     activity.browser     = request.env['HTTP_USER_AGENT']
  #     activity.ip_address  = request.env['REMOTE_ADDR']
  # 
  #     #--- what are they doing?
  #     activity.controller = controller_name
  #     activity.action     = action_name
  #     activity.params     = params.to_json
  #     activity.slug       = params['slug'] unless params['slug'].blank?
  #     activity.lesson     = [params['course_slug'], params['lesson_slug'], params['content_slug']].join(',') unless params['course_slug'].blank?
  # 
  #     activity.save!
  #   end
  # end
  
  # Sets the default value for the url options.  Seems to allow links/redirect_to
  # to have the proper value for the locale in the url
  #------------------------------------------------------------------------------
  def default_url_options(options={})
    options.merge({ locale: I18n.locale })
  end

  # try to weed out missing asset requests - if we make it here and the path starts
  # with 'site_assets', then missing asset was requested, 404 out quickly
  #------------------------------------------------------------------------------
  def check_site_assets
    if request.path.start_with?('/site_assets')
      render(file: 'public/404.html', status: :not_found, layout: false) && false
    else
      true
    end
  end

  # Set the locale of this request.
  #------------------------------------------------------------------------------
  def set_locale
    begin
      DmCore::Language.locale = (!params[:locale].blank? ? params[:locale] : current_account.preferred_default_locale)
    rescue I18n::InvalidLocale
      # if it's an invalid locale, append the default locale and try again
      # this also fixes the case of using simple link names on a hoem page.
      # So if home page is "http://example.com" and the link is <a href="calendar">
      # then the link is "http://example.com/calendar", instead of "http://example.com/en/calendar"
      # This will allow that to work.
      redirect_to "/#{current_account.preferred_default_locale}#{request.path}"
    end    
  end
  
  # Update the user's last_access if signed_in
  #------------------------------------------------------------------------------
  def update_user
    current_user.update_last_access if current_user && signed_in?
  end

  # Used for accessing a presenter inside a controller
  #------------------------------------------------------------------------------
  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    klass.new(object, view_context)
  end
  
  # FORCE to implement content_for in controller.  This is so we can use it in
  # the pages_controller to set the page title
  #------------------------------------------------------------------------------
  def view_context
    super.tap do |view|
      (@_content_for || {}).each do |name,content|
        view.content_for name, content
      end
    end
  end
  def content_for(name, content) # no blocks allowed yet
    @_content_for ||= {}
    if @_content_for[name].respond_to?(:<<)
      @_content_for[name] << content
    else
      @_content_for[name] = content
    end
  end
  def content_for?(name)
    @_content_for[name].present?
  end

  # determine what filters are set for this controller - useful for debugging
  #------------------------------------------------------------------------------
  def self.filters(kind = nil)
    all_filters = _process_action_callbacks
    all_filters = all_filters.select{|f| f.kind == kind} if kind
    all_filters.map(&:filter)
  end

  def self.before_filters
    filters(:before)
  end

  def self.after_filters
    filters(:after)
  end

  def self.around_filters
    filters(:around)
  end

  # Store any additional data to be used by the ExceptionNotification gem
  #------------------------------------------------------------------------------
  def log_additional_data
    request.env["exception_notifier.exception_data"] = { :user => current_user, :account => current_account }
  end

  # Note: rescue_from should be listed from generic exception to most specific
  #------------------------------------------------------------------------------
  rescue_from CanCan::AccessDenied do |exception|
    #--- Redirect to the index page if we get an access denied
    redirect_to main_app.root_url, :alert => exception.message
  end
  rescue_from Account::LoginRequired do |exception|
    #--- Redirect to the login page
    store_location_for(:user, request.url) # so we get returned here after login
    redirect_to main_app.new_user_session_path, :alert => exception.message
  end
  rescue_from Account::DomainNotFound do |exception|
    #--- log the invalid domain and render nothing.
    logger.error "=====> #{exception.message}  URL: #{request.url}  REMOTE_ADDR: #{request.remote_addr}"
    render :nothing => true
  end
  rescue_from I18n::InvalidLocale do |exception|
    #--- an invalid locale was specified - raise error to show 404 page
    raise ActionController::RoutingError.new('Not Found')
  end
end
