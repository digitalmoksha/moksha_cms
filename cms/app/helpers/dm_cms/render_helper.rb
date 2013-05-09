#------------------------------------------------------------------------------
module DmCms
  module RenderHelper

    #------------------------------------------------------------------------------
    def main_title
      title = current_account.preferred_site_title
      content_for?(:page_title) ? "#{content_for :page_title} | #{title}" : title
    end

    # Returns an image tag, where the src defaults to the site_assets image folder
    # Supports both relative paths and explicit url
    #------------------------------------------------------------------------------
    def site_image_tag(src, options = {})
      src = expand_url(src, "#{account_site_assets}/images/")
      image_tag(src,  options)
    end

    # Returns a path to a site assets, relative to the site_assets folder
    # Supports both relative paths and explicit url
    #------------------------------------------------------------------------------
    def site_asset(src, options = {})
      src = expand_url(src, "#{account_site_assets}/")
      image_tag(src,  options)
    end

    # insert the standard google analystics code, is tracker id set in account
    #------------------------------------------------------------------------------
    def google_analytics_tag
      if Rails.env.production? && !current_account.preferred_google_analytics_tracker_id.blank?
        x = <<-CMD
        <script>
            var _gaq=[['_setAccount','#{current_account.preferred_google_analytics_tracker_id}'],['_setDomainName','#{current_account.domain}'],['_setCustomVar',1,'logged-in','subscriber',1],['_trackPageview'],['_addIgnoredRef', '#{current_account.domain}']];
            (function(d,t){var g=d.createElement(t),s=d.getElementsByTagName(t)[0];
            g.src=('https:'==location.protocol?'//ssl':'//www')+'.google-analytics.com/ga.js';
            s.parentNode.insertBefore(g,s)}(document,'script'));
        </script>
        CMD
        x.html_safe
      end
    end

  end
end