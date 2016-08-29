module DmCms
  module PermittedParams

    #------------------------------------------------------------------------------
    def cms_snippet_params
      params.require(:cms_snippet).permit! if can? :manage_content, :all
    end

    #------------------------------------------------------------------------------
    def cms_blog_params
      params.require(:cms_blog).permit! if can? :manage_content, :all
    end

    #------------------------------------------------------------------------------
    def cms_post_params
      params.require(:cms_post).permit! if can? :manage_content, :all
    end

    #------------------------------------------------------------------------------
    def cms_page_params
      params.require(:cms_page).permit! if can? :manage_content, :all
    end

    #------------------------------------------------------------------------------
    def cms_contentitem_params
      params.require(:cms_contentitem).permit! if can? :manage_content, :all
    end

    #------------------------------------------------------------------------------
    def media_file_params
      params.require(:media_file).permit! if can? :manage_content, :all
    end
  end
end