class DmCore::Admin::UsersController < DmCore::Admin::AdminController
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
      if @user.update_attributes(params[:user])
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
  
private

  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def template_setup
    content_for :content_title, "#{icons('font-user')} User Management".html_safe
  end

end
