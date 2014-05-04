module DmCms
  module PermittedParams

    #------------------------------------------------------------------------------
    def cms_snippet_params
      params.require(:cms_snippet).permit! if current_user.try(:is_admin?)
    end

    #------------------------------------------------------------------------------
    def cms_blog_params
      params.require(:cms_blog).permit! if current_user.try(:is_admin?)
    end

    #------------------------------------------------------------------------------
    def cms_post_params
      params.require(:cms_post).permit! if current_user.try(:is_admin?)
    end

    #------------------------------------------------------------------------------
    def cms_page_params
      params.require(:cms_page).permit! if current_user.try(:is_admin?)
    end

    #------------------------------------------------------------------------------
    def cms_contentitem_params
      params.require(:cms_contentitem).permit! if current_user.try(:is_admin?)
    end

    #------------------------------------------------------------------------------
    def media_file_params
      params.require(:media_file).permit! if current_user.try(:is_admin?)
    end
  end
end