module DmCms
  module AnalyticsHelper
    # Will insert the google analytics code. First it checks that the GA code was
    # specified in the account.  If a theme wants different/more complex analytics
    # code, then they can override the 'customized/analytics/google_analytics' partial
    #------------------------------------------------------------------------------
    def google_analytics_tag
      if Rails.env.production?
        unless (tracking_id = current_account.preferred_google_analytics_tracker_id).blank?
          render partial: 'customized/analytics/google_analytics', locals: { tracking_id: tracking_id, domain_name: current_account.domain }
        end
      end
    end

    #------------------------------------------------------------------------------
    def mint_tag
      # if Rails.env.production? && !request.ssl?
      #   "" # [todo] "<script src='/mint/?js' type='text/javascript'></script>".html_safe
      # elsif Rails.env.production? && request.ssl?
      #   "" # [todo] "<script src='/mint/?js' type='text/javascript'></script>".html_safe
      # end
    end
  end
end