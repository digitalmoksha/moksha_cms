class DmCms::BlogsController < DmCms::ApplicationController
  include ApplicationHelper  

  helper DmCms::RenderHelper
  helper DmCore::LiquidHelper
  helper DmCms::PagesHelper
  include DmCore::RenderHelper

  before_filter   :blog_lookup, :except =>  [:list, :categories]

  layout    'cms_templates/blog', :only => [:list, :show, :categories]
  
  #------------------------------------------------------------------------------
  def categories
    @forum_categories = ForumCategory.ordered
  end
  
  #------------------------------------------------------------------------------
  def list
    @blogs = CmsBlog.available_to_user(current_user)
  end

  #------------------------------------------------------------------------------
  def show
    @posts = @blog.posts
  end

protected

  #------------------------------------------------------------------------------
  def blog_lookup
    @blog = CmsBlog.find_by_slug!(params[:id])
    authorize! :read, @blog
  end

end
