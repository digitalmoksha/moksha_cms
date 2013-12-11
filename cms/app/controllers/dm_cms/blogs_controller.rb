class DmCms::BlogsController < DmCms::ApplicationController
  include ApplicationHelper  

  helper  DmCms::RenderHelper
  helper  DmCore::LiquidHelper
  helper  DmCms::PagesHelper
  helper  DmCms::PostsHelper
  include DmCore::RenderHelper

  before_filter   :blog_lookup, :except =>  [:index]

  layout    'cms_templates/blog', :only => [:index, :show]
  
  #------------------------------------------------------------------------------
  def index
    @blogs        = CmsBlog.available_to_user(current_user)
    @posts        = CmsPost.where(cms_blog_id: @blogs.map(&:id)).published.order('published_on DESC').paginate page: page_number
    @recent_posts = CmsPost.where(cms_blog_id: @blogs.map(&:id)).published.order('published_on DESC').limit(5)
    render action: :show
  end

  #------------------------------------------------------------------------------
  def show
    @blogs        = CmsBlog.available_to_user(current_user)
    @posts        = @blog.posts.paginate :page => page_number
    @recent_posts = @blog.posts.limit(5)
  end

protected

  #------------------------------------------------------------------------------
  def blog_lookup
    @blog = CmsBlog.find(params[:id])
    redirect_to blog_root_path and return if @blog.nil?
    authorize! :read, @blog
  end

end
