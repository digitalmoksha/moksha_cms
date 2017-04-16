class DmCms::Admin::CmsBlogsController < DmCms::Admin::AdminController
  include DmCms::PermittedParams
  
  before_action   :blog_lookup,    :except =>  [:index, :new, :create]
  #before_action   :set_title
  
  #------------------------------------------------------------------------------
  def index
    authorize! :access_content_section, :all
    @blogs = can?(:manage_content, :all) ? CmsBlog.all : CmsBlog.with_role(:manage_content, current_user)
  end

  #------------------------------------------------------------------------------
  def new
    authorize! :manage_content, :all
    @blog = CmsBlog.new
  end

  #------------------------------------------------------------------------------
  def create
    authorize! :manage_content, :all
    @blog = CmsBlog.new(cms_blog_params)
    
    if @blog.save
      redirect_to admin_cms_blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render action: :new
    end
  end

  #------------------------------------------------------------------------------
  def edit
    authorize! :manage_content, @blog
  end

  #------------------------------------------------------------------------------
  def update
    authorize! :manage_content, @blog
    if @blog.update_attributes(cms_blog_params)
      redirect_to admin_cms_blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render action: :edit
    end
  end
  
  #------------------------------------------------------------------------------
  def show
    authorize! :manage_content, @blog
  end

  #------------------------------------------------------------------------------
  def destroy
    authorize! :manage_content, :all
    @blog.destroy
    redirect_to admin_cms_blogs_url
  end
  
  #------------------------------------------------------------------------------
  def sort
    if can? :manage_content, :all
      @blog.update_attribute(:row_order_position, params[:item][:row_order_position])
    end

    #--- this action will be called via ajax
    head :ok
  end

  #------------------------------------------------------------------------------
  def blog_users
    authorize! :manage_content, @blog
    respond_to do |format|
      format.json { render json: BlogUserDatatable.new(view_context, @blog) }
    end
  end
  
  # Add user(s) to blog
  # => user_id: add a single user
  #------------------------------------------------------------------------------
  def blog_add_member
    authorize! :manage_content, @blog
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
    authorize! :manage_content, @blog
    user = User.find(params[:user_id])
    @blog.remove_member(user)
    redirect_to admin_cms_blog_url(@blog), notice: "Blog access removed for #{user.full_name}"
  end

  #------------------------------------------------------------------------------
  def permissions
    authorize! :manage_content, :all
    if put_or_post?
      if params[:user][:user_id]
        user = User.find(params[:user][:user_id])
        if user
          roles = params[:user].delete(:roles)
          [:manage_content].each do |role|
            roles[role].as_boolean ? user.add_role(role, @blog) : user.remove_role(role, @blog)
          end
          user.save!
        end
      end
    end
    @content_managers = User.with_role(:content_manager)
    @content_managers_alacarte = User.with_role(:content_manager_alacarte)
  end

  #------------------------------------------------------------------------------
  def ajax_toggle_permission
    authorize! :manage_content, :all
    user = User.find(params[:user_id])
    role = params[:role].to_sym
    if user && [:manage_content].include?(role)
      user.has_role?(role, @blog) ? user.remove_role(role, @blog) : user.add_role(role, @blog)
      user.save!
    end
    head :ok
  end

private

  #------------------------------------------------------------------------------
  def blog_lookup
    @blog = CmsBlog.friendly.find(params[:id])
  end

end
