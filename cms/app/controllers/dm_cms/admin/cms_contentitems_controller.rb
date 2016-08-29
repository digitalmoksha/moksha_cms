class DmCms::Admin::CmsContentitemsController < DmCms::Admin::AdminController
  include DmCms::PermittedParams
  include DmCore::LiquidHelper

  before_filter   :current_page,    :only =>    [:new_content, :create_content]
  before_filter   :current_content, :except =>  [:new_content, :create_content]
  before_filter   :set_title

  #------------------------------------------------------------------------------
  def new_content
    @cms_contentitem        = CmsContentitem.new
    @cms_contentitem.container  = 'body'
  end

  #------------------------------------------------------------------------------
  def create_content
    @cms_contentitem = @current_page.cms_contentitems.new(cms_contentitem_params)
    if @cms_contentitem.save
      redirect_to admin_cms_page_url(@current_page), notice: 'Content successfully created.'
    else
      render action: "new_content", notice: 'Content successfully created.'
    end
  end

  #------------------------------------------------------------------------------
  def edit
  end

  #------------------------------------------------------------------------------
  def update
    if @cms_contentitem.update_attributes(cms_contentitem_params)
      redirect_to edit_admin_cms_contentitem_url(@cms_contentitem), notice: 'Content updated'
     else
      render :action => :edit, alert: 'An error of some kind occurred'
     end
  end

  #------------------------------------------------------------------------------
  def destroy
    @cms_contentitem.destroy
    redirect_to(:controller => 'dm_cms/admin/cms_pages', :action => :show, :id => @cms_contentitem.cms_page_id)
  end

  #------------------------------------------------------------------------------
  def update_fragment
    if @cms_contentitem.update_attributes(cms_contentitem_params)
      #@cms_page.merge!(@item.cms_page.get_page_render_values)
      #respond_to do |format| 
      #  format.js { render :action => :update_fragment } 
      #end
    end
  end

  #------------------------------------------------------------------------------
  def move_up
    @cms_contentitem.update_attributes(row_order_position: :up)
    redirect_to(:controller => 'dm_cms/admin/cms_pages', :action => :show, :id => @cms_contentitem.cms_page_id)
  end

  #------------------------------------------------------------------------------
  def move_down
    @cms_contentitem.update_attributes(row_order_position: :down)
    redirect_to(:controller => 'dm_cms/admin/cms_pages', :action => :show, :id => @cms_contentitem.cms_page_id)
  end
  
  #------------------------------------------------------------------------------
  def markdown
    @text = ''
    if put_or_post?
      @text = params[:sample_text][:markdown]
    end
  end

protected
  
  #------------------------------------------------------------------------------
  def current_page
    @current_page  = CmsPage.friendly.find(params[:id])
  end

  #------------------------------------------------------------------------------
  def current_content
    @cms_contentitem  = CmsContentitem.find(params[:id]) unless params[:id].to_i == 0
    @current_page     = @cms_contentitem.cms_page
  end

private

  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def set_title
    text = @current_page.nil? ? 'Pages' : present(@current_page).admin_edit_title
    content_for :content_title, text
  end

end