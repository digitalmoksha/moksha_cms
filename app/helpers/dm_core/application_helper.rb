module DmCore
  module ApplicationHelper

    # Used for accessing a models presenter object - can also accept a block
    #------------------------------------------------------------------------------
    def present(object, klass = nil)
      klass ||= "#{object.class}Presenter".constantize
      presenter = klass.new(object, self)
      yield presenter if block_given?
      presenter
    end

    #------------------------------------------------------------------------------
    def flash_notices
      #--- use Bootstrap class values
      flash_class = {:notice => 'alert-success', :error => 'alert-error', :alert => 'alert-info'}
      raw([:notice, :error, :alert].collect {|type| content_tag('div', flash[type], :id => type, :class => "alert #{flash_class[type]}") if flash[type] }.join)
    end
  
    #------------------------------------------------------------------------------
    def is_admin?
      user_signed_in? && current_user.is_admin?
    end

    #------------------------------------------------------------------------------
    def is_sysadmin?
      user_signed_in? && current_user.is_sysadmin?
    end
  
    # for determining if use is on a paritcular page, for active nav highlighting
    # http://stackoverflow.com/questions/3705898/best-way-to-add-current-class-to-nav-in-rails-3
    #------------------------------------------------------------------------------
    def controller?(*controller)
      controller.include?(params[:controller])
    end

    #------------------------------------------------------------------------------
    def action?(*action)
      action.include?(params[:action])
    end

    #------------------------------------------------------------------------------
    def put_or_post? 
      request.put? || request.post?
    end
  end
end
