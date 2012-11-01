module DmCore
  module ApplicationHelper
    #------------------------------------------------------------------------------
    def flash_notices
      #--- use Bootstrap class values
      flash_class = {:notice => 'alert-success', :error => 'alert-error', :alert => 'alert-info'}
      raw([:notice, :error, :alert].collect {|type| content_tag('div', flash[type], :id => type, :class => "alert #{flash_class[type]}") if flash[type] }.join)
    end
  
    # Usually don't care if a form submits a PUT or POST.  Was something submitted?
    #------------------------------------------------------------------------------
    def put_or_post?
      request.put? || request.post?
    end
  
    #------------------------------------------------------------------------------
    def is_admin?
      user_signed_in? && current_user.is_admin?
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

  end
end
