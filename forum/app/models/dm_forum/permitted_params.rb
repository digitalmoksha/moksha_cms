module DmForum
  module PermittedParams
    #------------------------------------------------------------------------------
    def forum_site_params
      params.require(:forum_site).permit! if can? :manage_forums, :all
    end

    #------------------------------------------------------------------------------
    def forum_category_params
      params.require(:forum_category).permit! if can? :manage_forums, :all
    end

    #------------------------------------------------------------------------------
    def forum_params
      params.require(:forum).permit! if can? :manage_forums, :all
    end

    #------------------------------------------------------------------------------
    def forum_topic_params
      if can? :manage_forums, :all
        params.require(:forum_topic).permit!
      else
        params.require(:forum_topic).permit(:title, :body)
      end
    end

    #------------------------------------------------------------------------------
    def forum_comment_params
      if can? :manage_forums, :all
        params.require(:forum_comment).permit!
      else
        params.require(:forum_comment).permit(:title, :body)
      end
    end
  end
end
