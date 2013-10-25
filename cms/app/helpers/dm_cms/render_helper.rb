#------------------------------------------------------------------------------
module DmCms
  module RenderHelper

    # build title to use on a page
    #------------------------------------------------------------------------------
    def page_title
      title = current_account.preferred_site_title
      content_for?(:page_title) ? "#{content_for :page_title} | #{title}" : title
    end
    alias :main_title :page_title  # keep old main_title around for now

    # keywords to use in meta name='keywords'
    #------------------------------------------------------------------------------
    def page_keywords
      content_for?(:page_keywords) ? content_for(:page_keywords) : current_account.preferred_site_keywords
    end

    # copyright to use in meta name='copyright'
    #------------------------------------------------------------------------------
    def page_copyright
      content_for?(:page_copyright) ? content_for(:page_copyright) : current_account.preferred_site_copyright
    end

    # description to use in meta name='description'
    #------------------------------------------------------------------------------
    def page_description
      content_for?(:page_description) ? content_for(:page_description) : current_account.preferred_site_description
    end

    #------------------------------------------------------------------------------
    def social_url(name)
      case name
      when :facebook
        current_account.preferred_facebook_url
      when :youtube
        current_account.preferred_youtube_url
      when :twitter
        current_account.preferred_twitter_url
      when :linkedin
        current_account.preferred_linkedin_url
      else
        nil
      end
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