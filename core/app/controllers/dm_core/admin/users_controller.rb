class DmCore::Admin::UsersController < DmCore::Admin::AdminController
  before_filter :authorize_access
  before_filter :template_setup, except: [:edit]

  # GET /admin/users or GET /admin/users.json
  #------------------------------------------------------------------------------
  def index
    #@users = User.paginate :page => params[:page], :per_page => 25

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: UserDatatable.new(view_context) }
    end
  end

  # GET /admin/users/1 or GET /admin/users/1.json
  #------------------------------------------------------------------------------
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /admin/users/1/edit
  #------------------------------------------------------------------------------
  def edit
    @user = User.find(params[:id])
  end

  # PUT /admin/users/1 or PUT /admin/users/1.json
  #------------------------------------------------------------------------------
  def update
    @user = User.find(params[:id])
    respond_to do |format|
      roles = params[:user].delete(:roles)
      if params[:user].empty? || @user.update_attributes(user_params)
        @user.update_roles(roles, is_admin?) if roles
        format.html { redirect_to dm_core.admin_users_url, notice: "'#{@user.display_name}' was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/users/1 or DELETE /admin/users/1.json
  #------------------------------------------------------------------------------
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to dm_core.admin_users_url }
      format.json { head :no_content }
    end
  end
  
  # Change to a different user, so we can check their permissions, etc
  #------------------------------------------------------------------------------
  def masquerade
    @user = User.find(params[:id])
    if @user
      switch_user(@user)
      redirect_to main_app.root_url
    else
      redirect_to :action => :list
    end
  end

  #------------------------------------------------------------------------------
  def confirm
    @user = User.find(params[:id])
    if @user && !@user.confirmed?
      if @user.confirm
        redirect_to dm_core.admin_users_url, notice: 'User is now confirmed and should be able to login'
      else
        redirect_to dm_core.edit_admin_user_path(@user), alert: "A problem occurred, unable to confirm user"
      end
    else
      redirect_to dm_core.edit_admin_user_path(@user), alert: 'User is already confirmed'
    end
  end
  
protected

  #------------------------------------------------------------------------------
  def authorize_access
    unless can? :manage, :all
      flash[:alert] = "Unauthorized Access!"
      redirect_to current_account.index_path 
    end
  end

private

  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def template_setup
    content_for :content_title, "User Management"
  end

end