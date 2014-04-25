class DmCms::Admin::CmsBlogsController < DmCms::Admin::AdminController
  include DmCms::PermittedParams
  
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
    @blog = CmsBlog.new(cms_blog_params)
    
    if @blog.save
      redirect_to admin_cms_blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render action: :new
    end
  end

  #------------------------------------------------------------------------------
  def update
    if @blog.update_attributes(cms_blog_params)
      redirect_to admin_cms_blog_url(@blog), notice: 'Blog was successfully updated.'
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

  #------------------------------------------------------------------------------
  def blog_users
    respond_to do |format|
      format.json { render json: BlogUserDatatable.new(view_context, @blog) }
    end
  end
  
  # Add user(s) to blog
  # => user_id: add a single user
  #------------------------------------------------------------------------------
  def blog_add_member
    if !params[:user_id].blank?
      user = User.find(params[:user_id])
      @blog.add_member(user)
      redirect_to admin_cms_blog_url(@blog), notice: "Blog access granted for #{user.full_name}"
    else
      redirect_to admin_cms_blog_url(@blog), alert: "Incorrect parameters supplied"
    end
  end
  
  #------------------------------------------------------------------------------
  def blog_delete_member
    user = User.find(params[:user_id])
    @blog.remove_member(user)
    redirect_to admin_cms_blog_url(@blog), notice: "Blog access removed for #{user.full_name}"
  end

private

  #------------------------------------------------------------------------------
  def blog_lookup
    @blog = CmsBlog.friendly.find(params[:id])
  end

end
