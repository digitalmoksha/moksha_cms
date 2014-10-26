class DmCms::Admin::CmsPostsController < DmCms::Admin::AdminController
  include DmCms::PermittedParams

  before_filter   :blog_lookup, :only =>    [:index, :new, :create]
  before_filter   :post_lookup, :except =>  [:index, :new, :create]
  
  #------------------------------------------------------------------------------
  def index
    @posts = @blog.posts
  end

  #------------------------------------------------------------------------------
  def show
  end

  #------------------------------------------------------------------------------
  def new
    @post = @blog.posts.build(comments_allowed: @blog.comments_allowed)
  end

  #------------------------------------------------------------------------------
  def edit
  end

  #------------------------------------------------------------------------------
  def create
    @post = @blog.posts.new(cms_post_params)

    if @post.save
      redirect_to admin_cms_blog_url(@blog), notice: 'Post was successfully created.'
    else
      render action: :new
    end
  end

  #------------------------------------------------------------------------------
  def update
    if @post.update_attributes(cms_post_params)
      redirect_to admin_cms_blog_url(@blog), notice: 'Post was successfully updated.'
    else
      render action: :edit
    end
  end

  #------------------------------------------------------------------------------
  def destroy
    @post.destroy
    redirect_to admin_cms_blog_url(@blog), notice: 'Post was successfully deleted.'
  end
  
  #------------------------------------------------------------------------------
  def send_notifications_emails
    status = @post.send_notification_emails(params[:test] ? current_user : nil)
    redirect_to admin_cms_blog_url(@blog), notice: "Notification emails sent ==>  Success: #{status[:success]}  Failed: #{status[:failed]}"
  end

private

  #------------------------------------------------------------------------------
  def blog_lookup
    @blog = CmsBlog.friendly.find(params[:cms_blog_id])
  end

  #------------------------------------------------------------------------------
  def post_lookup
    @post = CmsPost.friendly.find(params[:id])
    @blog = @post.cms_blog
  end

end
