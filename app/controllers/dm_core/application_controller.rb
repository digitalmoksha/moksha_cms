module DmCore
  class ApplicationController < ActionController::Base

    before_filter   :set_locale
    before_filter   :set_mailer_url_options

  protected
  
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
  end
end
