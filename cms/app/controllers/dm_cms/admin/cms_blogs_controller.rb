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
      redirect_to admin_cms_blog_url(@log), notice: 'Blog was successfully created.'
    else
      render action: :new
    end
  end

  #------------------------------------------------------------------------------
  def update
    if @blog.update_attributes(params[:cms_blog])
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
  # => workshop_id: add all attending users, ignore duplicates
  #------------------------------------------------------------------------------
  def blog_add_member
    if !params[:user_id].blank?
      user = User.find(params[:user_id])
      user.add_role(:member, @blog)
      redirect_to admin_cms_blog_url(@blog), notice: "Blog access granted for #{user.full_name}"
    elsif !params[:workshop_id].blank?
      workshop  = Workshop.find(params[:workshop_id])
      added     = 0
      workshop.registrations.attending.each do |r|
        if r.user_profile.user && !r.user_profile.user.has_role?(:member, @blog)
          r.user_profile.user.add_role(:member, @blog)
          added += 1
        end
      end
      redirect_to admin_cms_blog_url(@blog), notice: "Blog access granted for #{added} user(s)"
    else
      redirect_to admin_cms_blog_url(@blog), alert: "Incorrect parameters supplied"
    end
  end
  
  #------------------------------------------------------------------------------
  def blog_delete_member
    user = User.find(params[:user_id])
    user.remove_role(:member, @blog)
    redirect_to admin_cms_blog_url(@blog), notice: "Blog access removed for #{user.full_name}"
  end

private

  #------------------------------------------------------------------------------
  def blog_lookup
    @blog = CmsBlog.find(params[:id])
  end

end
