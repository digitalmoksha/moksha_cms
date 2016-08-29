class DmCms::Admin::CmsPostsController < DmCms::Admin::AdminController
  include DmCms::PermittedParams

  before_filter   :blog_lookup
  before_filter   :post_lookup, :except =>  [:new, :create]
  
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
    if params[:test] && status == 0
      redirect_to admin_cms_blog_url(@blog), error: "Unable to send test email"
    else
      msg = params[:test] ? "Test notification sent to #{current_user.email}" : "#{status} emails are being sent"
      redirect_to admin_cms_blog_url(@blog), notice: msg
    end
  end

private

  # the blog needs to be specified in the url for each post.  post slugs are
  # unique per blog
  #------------------------------------------------------------------------------
  def blog_lookup
    @blog = CmsBlog.friendly.find(params[:cms_blog_id])
  end

  #------------------------------------------------------------------------------
  def post_lookup
    @post = @blog.posts.friendly.find(params[:id])
  end

end
