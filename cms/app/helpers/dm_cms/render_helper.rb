#------------------------------------------------------------------------------
module DmCms
  module RenderHelper
    include DmCms::AnalyticsHelper

    # build title to use on a page
    # note: make sure we return a properly escpaed html_safe string
    #------------------------------------------------------------------------------
    def page_title
      title = current_account.preferred_site_title
      content_for?(:page_title) ? "#{h(content_for :page_title)} | #{h(title)}".html_safe : h(title)
    end
    alias :main_title :page_title # keep old main_title around for now

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
      when :vimeo
        current_account.preferred_vimeo_url
      when :twitter
        current_account.preferred_twitter_url
      when :linkedin
        current_account.preferred_linkedin_url
      else
        nil
      end
    end
  end
end