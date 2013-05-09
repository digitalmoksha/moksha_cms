class DmCms::Admin::CmsBlogsController < DmCms::Admin::AdminController
  
  before_filter   :blog_lookup,    :except =>  [:index, :new, :create]
  #before_filter   :set_title
  
  #------------------------------------------------------------------------------
  def index
    @blogs = CmsBlog.all
  end

  #------------------------------------------------------------------------------
  def new
    @blog = CmsBlog.new
  end

  #------------------------------------------------------------------------------
  def edit
  end

  #------------------------------------------------------------------------------
  def create
    @blog = CmsBlog.new(params[:cms_blog])
    
    if @blog.save
      redirect_to admin_cms_blogs_url, notice: 'Blog was successfully created.'
    else
      render action: :new
    end
  end

  #------------------------------------------------------------------------------
  def update
    if @blog.update_attributes(params[:cms_blog])
      redirect_to admin_cms_blogs_url, notice: 'Blog was successfully updated.'
    else
      render action: :edit
    end
  end

  #------------------------------------------------------------------------------
  def destroy
    @blog.destroy

    redirect_to admin_cms_blogs_url
  end
  
  #------------------------------------------------------------------------------
  def sort
    @blog.update_attribute(:row_order_position, params[:item][:row_order_position])

    #--- this action will be called via ajax
    render nothing: true
  end
  
private

  #------------------------------------------------------------------------------
  def blog_lookup
    @blog = CmsBlog.find(params[:id])
  end

end
