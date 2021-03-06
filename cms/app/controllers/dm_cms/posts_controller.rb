class DmCms::PostsController < DmCms::ApplicationController
  include ApplicationHelper

  helper  DmCms::RenderHelper
  helper  DmCore::LiquidHelper
  helper  DmCms::PagesHelper
  helper  DmCms::PostsHelper
  include DmCore::RenderHelper
  include DmCore::UrlHelper
  include DmCore::LiquidHelper

  before_action :post_lookup, except: [:ajax_delete_comment]

  layout 'cms_templates/blog_post'

  #------------------------------------------------------------------------------
  def show
    @blogs        = CmsBlog.available_to_user(current_user)
    @recent_posts = CmsPost.where(cms_blog_id: @blogs.map(&:id)).includes(:cms_blog, :translations).published.order('published_on DESC').limit(5)
    @comments     = @post.comments.paginate page: page_number

    #--- set title / meta data
    content_for :page_title, @post.title
    set_meta description: @post.summary, "og:description" => sanitize_text(markdown(@post.summary, safe: false))
    set_meta "og:image" => site_asset_media_url(@post.featured_image) if @post.featured_image.present?
  end

  #------------------------------------------------------------------------------
  def ajax_add_comment
    @post.comments.create(body: params[:comment][:body], user_id: current_user.id) if current_user && !params[:comment][:body].blank?
    respond_to do |format|
      format.html { redirect_back(fallback_location: post_show_url(@post)) }
      format.json { head :ok }
    end
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
  #   respond_to do |format|
  #     format.html { redirect_back(fallback_location: post_show_url(@post)) }
  #     format.json { head :ok }
  #   end
  # end

  #------------------------------------------------------------------------------
  def ajax_delete_comment
    if is_admin?
      comment = Comment.find(params[:id]).destroy
      post    = comment.commentable
      respond_to do |format|
        format.html { redirect_back(fallback_location: post_show_url(post)) }
        format.json { head :ok }
      end
    end
  end

  protected

  #------------------------------------------------------------------------------
  def post_lookup
    @blog = CmsBlog.friendly.find(params[:cms_blog_id])
    redirect_to(blog_root_path) && return if @blog.nil?

    raise Account::LoginRequired, I18n.t('cms.blog_login_required') if !current_user && !@blog.is_public?

    authorize! :read, @blog

    @post = @blog.posts.friendly.find(params[:id])
    redirect_to(blog_show_path(@blog)) && return if @post.nil?

    authorize! :read, @post
  end
end
