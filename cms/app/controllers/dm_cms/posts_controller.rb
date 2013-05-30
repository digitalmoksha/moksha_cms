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
    @blogs = CmsBlog.available_to_user(current_user)
    @posts = CmsPost.where(cms_blog_id: @blogs.map(&:id)).published.order('published_on DESC').paginate :page => page_number
  end

protected

  #------------------------------------------------------------------------------
  def post_lookup
    @blog = CmsBlog.find_by_slug!(params[:cms_blog_id])
    authorize! :read, @blog
    @post = @blog.posts.find_by_slug(params[:id])
  end

end
