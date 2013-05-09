module DmCore
  class ApplicationController < ActionController::Base

    around_filter   :scope_current_account

    before_filter   :record_activity
    before_filter   :set_locale
    before_filter   :set_mailer_url_options
    before_filter   :update_user
    before_filter   :theme_resolver
    before_filter   :site_enabled?, :unless => :devise_controller?
    before_filter   :ssl_redirect
    
    include DmCore::AccountHelper

    #------------------------------------------------------------------------------
    def index
      redirect_to "/#{current_account.preferred_default_locale}/index", :status => :moved_permanently
    end

  protected

    # if site is not enabled, only allow a logged in Admin user to access pages
    # otherwise, redirect to the 'coming_soon' page
    #------------------------------------------------------------------------------
    def site_enabled?
      unless current_account.site_enabled? || request.params['slug'] == 'coming_soon'
        # authenticate_user! 
        unless (user_signed_in? && (current_user.is_admin? || current_user.has_role?(:beta)))
          redirect_to "/#{current_account.preferred_default_locale}/coming_soon"
          return false
        end
     end
    end  

    #------------------------------------------------------------------------------
    def ssl_redirect
      if Rails.env.production? && current_account.ssl_enabled?
        if request.ssl? && !use_ssl? || !request.ssl? && use_ssl?
          protocol = request.ssl? ? "http" : "https"
          flash.keep
          redirect_to protocol: "#{protocol}://"
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

    #------------------------------------------------------------------------------
    def record_activity
      if Rails.env.production?
        activity = Activity.new

        #--- who is doing the activity?
        activity.session_id  = session['session_id'] unless session.nil?
        activity.user_id     = current_user.id unless current_user.nil?
        activity.browser     = request.env['HTTP_USER_AGENT']
        activity.ip_address  = request.env['REMOTE_ADDR']

        #--- what are they doing?
        activity.controller = controller_name
        activity.action     = action_name
        activity.params     = params.to_json
        activity.slug       = params['slug'] unless params['slug'].blank?
        activity.lesson     = [params['course_slug'], params['lesson_slug'], params['content_slug']].join(',') unless params['course_slug'].blank?

        activity.save!
      end
    end
    
    # Sets the default value for the url options.  Seems to allow links/redirect_to
    # to have the proper value for the locale in the url
    #------------------------------------------------------------------------------
    def default_url_options(options={})
      options.merge({ :locale => I18n.locale })
    end

    # Set the locale of this request.
    #------------------------------------------------------------------------------
    def set_locale
      DmCore::Language.locale = (!params[:locale].blank? ? params[:locale] : current_account.preferred_default_locale)
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

    # Redirect to the index page if we get an access denied
    #------------------------------------------------------------------------------
    rescue_from CanCan::AccessDenied do |exception|
      redirect_to main_app.root_url, :alert => exception.message
    end
  end
end
