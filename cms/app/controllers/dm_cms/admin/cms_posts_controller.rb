class DmCms::Admin::CmsPostsController < DmCms::Admin::AdminController

  before_filter   :blog_lookup, :only =>    [:index, :new, :create]
  before_filter   :post_lookup, :except =>  [:index, :new, :create]
  before_filter   :set_title
  
  #------------------------------------------------------------------------------
  def index
    @posts = @blog.posts
  end

  #------------------------------------------------------------------------------
  def show
  end

  #------------------------------------------------------------------------------
  def new
    @post = @blog.posts.build
  end

  #------------------------------------------------------------------------------
  def edit
  end

  #------------------------------------------------------------------------------
  def create
    prepare_date_time_attribute
    @post = @blog.posts.new(params[:cms_post])

    if @post.save
      redirect_to admin_cms_blog_url(@blog), notice: 'Post was successfully created.'
    else
      render action: :new
    end
  end

  #------------------------------------------------------------------------------
  def update
    prepare_date_time_attribute
    if @post.update_attributes(params[:cms_post])
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
  
private

  #------------------------------------------------------------------------------
  def blog_lookup
    @blog = CmsBlog.find(params[:cms_blog_id])
  end

  #------------------------------------------------------------------------------
  def post_lookup
    @post = CmsPost.find(params[:id])
    @blog = @post.cms_blog
  end

  #------------------------------------------------------------------------------
  def prepare_date_time_attribute
    date = params[:cms_post].delete(:published_on_date)
    time = params[:cms_post].delete(:published_on_time)
    params[:cms_post][:published_on] = (date.blank? ? Time.now : DateTime.parse(date + " " + time))
  end
  
  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def set_title
    content_for :content_title, @blog.title
  end
  
end
