class DmCms::BlogsController < DmCms::ApplicationController
  include ApplicationHelper

  helper  DmCms::RenderHelper
  helper  DmCore::LiquidHelper
  helper  DmCms::PagesHelper
  helper  DmCms::PostsHelper
  include DmCore::RenderHelper

  before_action   :blog_lookup, :except =>  [:index, :toggle_follow]

  layout    'cms_templates/blog', :only => [:index, :show]

  #------------------------------------------------------------------------------
  def index
    redirect_to(index_url) and return if CmsBlog.count == 0
    @blogs        = CmsBlog.available_to_user(current_user)
    @posts        = CmsPost.where(cms_blog_id: @blogs.map(&:id)).includes(:cms_blog, :translations).published.order('published_on DESC').paginate page: page_number
    @recent_posts = CmsPost.where(cms_blog_id: @blogs.map(&:id)).includes(:cms_blog, :translations).published.order('published_on DESC').limit(5)
    content_for :page_title, I18n.t('cms.blog_header')

    render action: :show
  end

  #------------------------------------------------------------------------------
  def show
    @blogs        = CmsBlog.available_to_user(current_user)
    @posts        = @blog.posts.includes(:cms_blog, :translations).published.order('published_on DESC').paginate :page => page_number
    @recent_posts = @blog.posts.includes(:cms_blog, :translations).published.order('published_on DESC').limit(5)
    content_for :page_title, (@blog ? @blog.title : I18n.t('cms.blog_header'))
  end

  #------------------------------------------------------------------------------
  def toggle_follow
    @blog = CmsBlog.friendly.find(params[:cms_blog_id])
    authorize! :read, @blog
    DmCore::ToggleFollowerService.new(current_user, @blog).call
  end

protected

  #------------------------------------------------------------------------------
  def blog_lookup
    @blog = CmsBlog.friendly.find(params[:id])
    redirect_to blog_root_path and return if @blog.nil?
    authorize! :read, @blog
  end

end
