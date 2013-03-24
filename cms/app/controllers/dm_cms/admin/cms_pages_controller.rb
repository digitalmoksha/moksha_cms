class DmCms::Admin::CmsPagesController < DmCore::Admin::AdminController
  helper "dm_cms/cms_pages"
  
  before_filter   :current_page, :except => [:file_tree, :expire_cache_total]
  before_filter   :set_title

  #------------------------------------------------------------------------------
  def index
    CmsPage.create_default_site if CmsPage.roots.empty?
    @tree = CmsPage.arrange
  end
  
  #------------------------------------------------------------------------------
  def new_page
    @cms_page = CmsPage.new
  end

  #------------------------------------------------------------------------------
  def create_page
    @current_page.children.create(params[:cms_page])
    redirect_to(:action => :index)
  end

  #------------------------------------------------------------------------------
  def edit
    @cms_page = @current_page
  end

  #------------------------------------------------------------------------------
  def update
    if @current_page.update_attributes(params[:cms_page])
      redirect_to :action => :show, :id => @current_page
     else
      @cms_page = @current_page
      render :action => :edit
     end
  end

  #------------------------------------------------------------------------------
  def show
  end
  
  # Given a new parent_id and position, place item in proper place
  # Note that position comes in as 0-based, increment to make 1-based
  #------------------------------------------------------------------------------
  def ajax_sort
    new_position = params[:item][:position].to_i + 1
    @current_page.update_attributes(:position => new_position, :parent_id => params[:item][:parent_id])

    #--- this action will be called via ajax
    render nothing: true
  end
  
  #------------------------------------------------------------------------------
  def move_up
    @current_page.move_higher
    redirect_to :action => :index
  end

  #------------------------------------------------------------------------------
  def move_down
    @current_page.move_lower
    redirect_to :action => :index
  end

  #------------------------------------------------------------------------------
  def destroy
    @current_page.destroy
    redirect_to :action => :index
  end

  # Based on jQuery File Tree Ruby Connector by Erik Lax
  # http://datahack.se, 13 July 2008
  #------------------------------------------------------------------------------
  def file_tree
    tree = "<ul class='jqueryFileTree' style='display: none;'>"
    slug = params[:dir].chomp("/")
    page = CmsPage.find_by_slug(slug)
    if page.nil?
      render :inline => 'Data Unavailable'
    else
      page.children.each do |child|
        if child.has_children?
      		tree += "<li class='directory collapsed'><a href='#' rel='#{child.slug}/'>#{child.slug}</a></li>";
        else
    			tree += "<li class='file'><a href='#' rel='#{child.slug}'>#{child.slug}</a></li>"
        end
      end
      tree += "</ul>"
      render :inline => tree
    end
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
      @current_page = CmsPage.find_by_slug(params[:id])
    else
      @current_page = CmsPage.find(params[:id])
    end
  end

  #------------------------------------------------------------------------------
  def theme_templates
    #HashWithIndifferentAccess.new(YAML.load(File.read(File.expand_path('../theme.yml', __FILE__))))
  end
  
private

  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def set_title
    text = @current_page.nil? ? 'Pages' : @current_page.title
    content_for :content_title, icon_label('font-paste', text)
  end

=begin
  #------------------------------------------------------------------------------
  def update_translation_front
    @page = current_account_site.cms_pages.find(params[:id])
    if @page.update_attributes(params[:cms_page])
      respond_to do |format| 
        format.html { flash[:notice] = 'Page was successfully updated.'; redirect_to :action => :edit, :id => @page; } 
        format.js { render :action => :update_translation_front } 
      end
    end
  end
=end
end
