class DmCms::Admin::CmsPagesController < DmCms::Admin::AdminController
  include DmCms::PermittedParams
  helper "dm_cms/cms_pages"
  
  before_filter   :current_page, :except => [:index, :file_tree, :expire_cache_total]

  #------------------------------------------------------------------------------
  def index
    CmsPage.create_default_site if CmsPage.roots.empty?
    # @tree = CmsPage.arrange(order: :position)
    @tree = CmsPage.arrange(order: :row_order)
  end
  
  #------------------------------------------------------------------------------
  def new_page
    @cms_page = CmsPage.new
  end

  #------------------------------------------------------------------------------
  def create_page
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
    @cms_page = @current_page
  end

  #------------------------------------------------------------------------------
  def update
    if @current_page.update_attributes(cms_page_params)
      redirect_to :action => :show, :id => @current_page
     else
      @cms_page = @current_page
      render :action => :edit
     end
  end

  #------------------------------------------------------------------------------
  def show
  end
  
  #------------------------------------------------------------------------------
  def duplicate_page
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
    @current_page.update_attributes(row_order_position: params[:item][:position], parent_id: params[:item][:parent_id])

    #--- this action will be called via ajax
    render nothing: true
  end
  
  #------------------------------------------------------------------------------
  def destroy
    @current_page.destroy
    redirect_to :action => :index
  end

  # Removes all cache files. This can be used when we're not sure if the
  # cache file for a changed page has been deleted or not
  #------------------------------------------------------------------------------
  def expire_cache_total
    expire_fragment(%r{\S})
    respond_to do |format| 
      format.html { redirect_to({:action => :index}, :notice => 'Page Cache was cleared') } 
      format.js { render :nothing => true }
    end
  end

protected
  
  #------------------------------------------------------------------------------
  def current_page
    if params[:id].to_i == 0
      @current_page = CmsPage.friendly.find(params[:id])
    else
      @current_page = CmsPage.find(params[:id])
    end
  end

end
