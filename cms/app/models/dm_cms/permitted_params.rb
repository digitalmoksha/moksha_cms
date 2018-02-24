module DmCms
  module PermittedParams
    #------------------------------------------------------------------------------
    def cms_snippet_params
      params.require(:cms_snippet).permit!
    end

    #------------------------------------------------------------------------------
    def cms_blog_params
      params.require(:cms_blog).permit!
    end

    #------------------------------------------------------------------------------
    def cms_post_params
      params.require(:cms_post).permit!
    end

    #------------------------------------------------------------------------------
    def cms_page_params
      params.require(:cms_page).permit!
    end

    #------------------------------------------------------------------------------
    def cms_contentitem_params
      params.require(:cms_contentitem).permit!
    end

    #------------------------------------------------------------------------------
    def media_file_params
      params.require(:media_file).permit!
    end
  end
end
