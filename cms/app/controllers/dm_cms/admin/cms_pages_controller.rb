class DmCms::Admin::CmsPagesController < DmCms::Admin::AdminController
  include DmCms::PermittedParams
  helper "dm_cms/cms_pages"

  before_action :current_page, :except => [:index, :file_tree, :expire_cache, :expire_cache_total]

  #------------------------------------------------------------------------------
  def index
    authorize! :access_content_section, :all
    CmsPage.create_default_site if CmsPage.roots.empty?
    # @tree = CmsPage.arrange(order: :position)
    @tree = CmsPage.includes(:translations).arrange(order: :row_order)
  end

  #------------------------------------------------------------------------------
  def new_page
    authorize! :manage_content, :all
    @cms_page = CmsPage.new
  end

  #------------------------------------------------------------------------------
  def create_page
    authorize! :manage_content, :all
    @cms_page = @current_page.children.new(cms_page_params)
    respond_to do |format|
      if @cms_page.save
        format.html { redirect_to admin_cms_page_url(@cms_page), notice: 'Page was successfully created.' }
        format.json { render json: @cms_page, status: :created, location: @cms_page }
      else
        format.html { render action: "new_page" }
        format.json { render json: @cms_page.errors, status: :unprocessable_entity }
      end
    end
  end

  #------------------------------------------------------------------------------
  def edit
    authorize! :manage_content, @current_page
    @cms_page = @current_page
  end

  #------------------------------------------------------------------------------
  def update
    authorize! :manage_content, @current_page
    if @current_page.update_attributes(cms_page_params)
      redirect_to :action => :show, :id => @current_page
    else
      @cms_page = @current_page
      render :action => :edit
    end
  end

  #------------------------------------------------------------------------------
  def show
    authorize! :manage_content, @current_page
  end

  #------------------------------------------------------------------------------
  def mark_welcome_page
    authorize! :manage_content, :all
    @current_page.mark_as_welcome_page
    redirect_to action: :show, id: @current_page
  end

  #------------------------------------------------------------------------------
  def duplicate_page
    authorize! :manage_content, :all
    new_page = @current_page.duplicate_with_associations
    if new_page.nil?
      redirect_to admin_cms_page_url(@current_page), :flash => { :error => 'A duplicate page already exists' }
    else
      redirect_to edit_admin_cms_page_url(new_page), :flash => { :notice => 'Duplicate page created.  Please customize it.' }
    end
  end

  # Given a new parent_id and position, place item in proper place
  # Note that position comes in as 0-based, increment to make 1-based
  #------------------------------------------------------------------------------
  def ajax_sort
    if can? :manage_content, :all
      @current_page.update_attributes(row_order_position: params[:item][:position], parent_id: params[:item][:parent_id])
    end

    #--- this action will be called via ajax
    head :ok
  end

  #------------------------------------------------------------------------------
  def destroy
    authorize! :manage_content, :all
    @current_page.destroy
    redirect_to :action => :index
  end

  # Removes all cache files for this account. This can be used when we're not sure if the
  # cache file for a changed page has been deleted or not
  #------------------------------------------------------------------------------
  def expire_cache
    #--- expire only items for this account
    key_start = fragment_cache_key(Account.current.id)
    expire_fragment(%r{\A#{key_start}})

    respond_to do |format|
      format.html { redirect_to({ :action => :index }, :notice => 'Page Cache was cleared') }
      format.js { head :ok }
    end
  end

  # Removes all cache files. This can be used when we're not sure if the
  # cache file for a changed page has been deleted or not
  #------------------------------------------------------------------------------
  def expire_cache_total
    expire_fragment(%r{\S})

    respond_to do |format|
      format.html { redirect_to({ :action => :index }, :notice => 'Page Cache for all sites cleared') }
      format.js { head :ok }
    end
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
            roles[role].as_boolean ? user.add_role(role, @current_page) : user.remove_role(role, @current_page)
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
      user.has_role?(role, @current_page) ? user.remove_role(role, @current_page) : user.add_role(role, @current_page)
      user.save!
    end
    head :ok
  end

  protected

  #------------------------------------------------------------------------------
  def current_page
    @current_page = CmsPage.friendly.find(params[:id])
  end
end
