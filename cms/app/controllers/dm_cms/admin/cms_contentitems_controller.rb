class DmCms::Admin::CmsContentitemsController < DmCore::Admin::AdminController

  before_filter :current_content, :except => [:new_content, :create_content]

  #------------------------------------------------------------------------------
  def new_content
    @cms_contentitem        = CmsContentitem.new
    @current_page           = CmsPage.find(params[:id])
    @cms_contentitem.container  = 'body'
  end

  #------------------------------------------------------------------------------
  def create_content
    @current_page           = CmsPage.find(params[:id])
    @current_page.cms_contentitems.create(params[:cms_contentitem])
    redirect_to(:controller => 'dm_cms/admin/cms_pages', :action => :show, :id => @current_page)
  end

  #------------------------------------------------------------------------------
  def edit
    @cms_contentitem = @current_content
  end

  #------------------------------------------------------------------------------
  def update
    if @current_content.update_attributes(params[:cms_contentitem])
      redirect_to(:controller => 'dm_cms/admin/cms_pages', :action => :show, :id => @current_content.cms_page_id)
     else
      @cms_page = @current_content
      render :action => :edit
     end
  end

  #------------------------------------------------------------------------------
  def destroy
    @current_content.destroy
    redirect_to(:controller => 'dm_cms/admin/cms_pages', :action => :show, :id => @current_content.cms_page_id)
  end

  #------------------------------------------------------------------------------
  def update_fragment
    if @current_content.update_attributes(params[:cms_contentitem])
      #@cms_page.merge!(@item.cms_page.get_page_render_values)
      #respond_to do |format| 
      #  format.js { render :action => :update_fragment } 
      #end
    end
  end

  #------------------------------------------------------------------------------
  def move_up
    @current_content.move_higher
    redirect_to(:controller => 'dm_cms/admin/cms_pages', :action => :show, :id => @current_content.cms_page_id)
  end

  #------------------------------------------------------------------------------
  def move_down
    @current_content.move_lower
    redirect_to(:controller => 'dm_cms/admin/cms_pages', :action => :show, :id => @current_content.cms_page_id)
  end

  protected
  
  #------------------------------------------------------------------------------
  def current_content
    @current_content  = CmsContentitem.find(params[:id]) unless params[:id].to_i == 0
    @current_page     = @current_content.cms_page
  end

private

  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def template_setup
    content_for :content_title, '<span class="icon-copy"></span>'.html_safe
  end

end
