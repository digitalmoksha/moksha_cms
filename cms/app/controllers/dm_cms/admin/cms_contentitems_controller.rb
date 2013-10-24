class DmCms::Admin::CmsContentitemsController < DmCms::Admin::AdminController

  before_filter   :current_page,    :only =>    [:new_content, :create_content]
  before_filter   :current_content, :except =>  [:new_content, :create_content]
  before_filter   :set_title

  include DmCore::LiquidHelper

  #------------------------------------------------------------------------------
  def new_content
    @cms_contentitem        = CmsContentitem.new
    @cms_contentitem.container  = 'body'
  end

  #------------------------------------------------------------------------------
  def create_content
    @cms_contentitem = @current_page.cms_contentitems.new(params[:cms_contentitem])
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
    if @cms_contentitem.update_attributes(params[:cms_contentitem])
      redirect_to(:controller => 'dm_cms/admin/cms_pages', :action => :show, :id => @cms_contentitem.cms_page_id)
     else
      render :action => :edit
     end
  end

  #------------------------------------------------------------------------------
  def destroy
    @cms_contentitem.destroy
    redirect_to(:controller => 'dm_cms/admin/cms_pages', :action => :show, :id => @cms_contentitem.cms_page_id)
  end

  #------------------------------------------------------------------------------
  def update_fragment
    if @cms_contentitem.update_attributes(params[:cms_contentitem])
      #@cms_page.merge!(@item.cms_page.get_page_render_values)
      #respond_to do |format| 
      #  format.js { render :action => :update_fragment } 
      #end
    end
  end

  #------------------------------------------------------------------------------
  def move_up
    @cms_contentitem.move_higher
    redirect_to(:controller => 'dm_cms/admin/cms_pages', :action => :show, :id => @cms_contentitem.cms_page_id)
  end

  #------------------------------------------------------------------------------
  def move_down
    @cms_contentitem.move_lower
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
    @current_page  = CmsPage.find(params[:id])
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
    text = @current_page.nil? ? 'Pages' : @current_page.title
    content_for :content_title, icon_label('font-paste', text)
  end

end
