module DmCore
  class ApplicationController < ActionController::Base

    around_filter   :scope_current_account

    before_filter   :set_locale
    before_filter   :set_mailer_url_options
    before_filter   :update_user
    
    before_filter   :theme_resolver
    
    include DmCore::AccountHelper

  protected
  
    # Choose the theme based on the account prefix in the Account
    #------------------------------------------------------------------------------
    def theme_resolver
      theme(current_account.account_prefix + '.default') if DmCore.config.enable_themes
    end

    #------------------------------------------------------------------------------
    def set_mailer_url_options
      ActionMailer::Base.default_url_options[:host] = request.host_with_port
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
      DmCore::Language.locale = params[:locale]
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

  end
end
