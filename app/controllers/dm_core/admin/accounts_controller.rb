class DmCore::Admin::AccountsController < DmCore::Admin::AdminController

  before_filter   :account_lookup

  # GET /admin/account or GET /admin/accounts/.json
  #------------------------------------------------------------------------------
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @account }
    end
  end

  # GET /admin/account/edit
  #------------------------------------------------------------------------------
  def edit
  end

  # PUT /admin/account or PUT /admin/account/.json
  #------------------------------------------------------------------------------
  def update
    respond_to do |format|
      if @account.update_attributes(params[:account])
        format.html { redirect_to dm_core.admin_account_url, notice: "Account was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

private

  #------------------------------------------------------------------------------
  def account_lookup
    @account = current_account
  end

  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def template_setup
    content_for :content_title, "#{icons('font-user')} Account Management".html_safe
  end

end
