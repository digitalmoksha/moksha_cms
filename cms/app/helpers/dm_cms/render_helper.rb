# To be overridden by application
#------------------------------------------------------------------------------
module DmCms
  module RenderHelper

    #------------------------------------------------------------------------------
    def main_title
      title = current_account.preferred_site_title
      content_for?(:page_title) ? "#{content_for :page_title} | #{title}" : title
    end
  end
end