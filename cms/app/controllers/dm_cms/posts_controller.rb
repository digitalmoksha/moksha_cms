class DmCms::PostsController < DmCms::ApplicationController
  include ApplicationHelper  

  helper DmCms::RenderHelper
  helper DmCore::LiquidHelper
  helper DmCms::PagesHelper
  include DmCore::RenderHelper

  before_filter   :post_lookup

  layout    'cms_templates/blog_post'
  
  #------------------------------------------------------------------------------
  def show
  end

protected

  #------------------------------------------------------------------------------
  def post_lookup
    @blog = CmsBlog.find_by_slug!(params[:cms_blog_id])
    authorize! :read, @blog
    @post = @blog.posts.find_by_slug(params[:id])
  end

end
