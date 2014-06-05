class DmCms::PostsController < DmCms::ApplicationController
  include ApplicationHelper  

  helper  DmCms::RenderHelper
  helper  DmCore::LiquidHelper
  helper  DmCms::PagesHelper
  helper  DmCms::PostsHelper
  include DmCore::RenderHelper
  include DmCore::UrlHelper
  include DmCore::LiquidHelper

  before_filter   :post_lookup, except: [:ajax_add_comment, :ajax_edit_comment, :ajax_delete_comment]

  layout    'cms_templates/blog_post'
  
  #------------------------------------------------------------------------------
  def show
    @blogs        = CmsBlog.available_to_user(current_user)
    @recent_posts = CmsPost.where(cms_blog_id: @blogs.map(&:id)).includes(:cms_blog, :translations).published.order('published_on DESC').limit(5)
    @comments     = @post.comments.paginate page: page_number

    #--- set title / meta data
    content_for :page_title, @post.title
    set_meta description: @post.summary, "og:description" => sanitize_text(markdown(@post.summary, safe: false))
    set_meta "og:image" => site_asset_media_url(@post.image) if @post.image.present?
  end

  #------------------------------------------------------------------------------
  def ajax_add_comment
    @post  = CmsPost.friendly.find(params[:cms_post_id])
    authorize! :read, @post.cms_blog
    @post.comments.create(:body => params[:comment][:body], :user_id => current_user.id) if current_user && !params[:comment][:body].blank?
    redirect_to :back
  end
  
  # #------------------------------------------------------------------------------
  # def ajax_edit_comment
  #   @comment  = Comment.find(params[:id])
  #   @post     = comment.commentable
  #   authorize! :read, @post.cms_blog
  # 
  #   if put_or_post?
  #   end
  #   
  #   @post.comments.create(:body => params[:comment][:body], :user_id => current_user.id)
  #   redirect_to :back
  # end
  
  #------------------------------------------------------------------------------
  def ajax_delete_comment
    if is_admin?
      Comment.find(params[:id]).destroy
    end
    redirect_to :back and return
  end
  
protected

  #------------------------------------------------------------------------------
  def post_lookup
    @blog = CmsBlog.friendly.find(params[:cms_blog_id])
    redirect_to blog_root_path and return if @blog.nil?
    raise Account::LoginRequired.new(I18n.t('cms.blog_login_required')) if !current_user && !@blog.is_public?
    authorize! :read, @blog
    
    @post = @blog.posts.friendly.find(params[:id])
    redirect_to blog_show_path(@blog) and return if @post.nil?
  end

end
