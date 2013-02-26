class DmCms::PagesController < DmCms::ApplicationController
  include ApplicationHelper  
  helper DmCms::RenderHelper
  helper DmCms::LiquidHelper
  
  #helper 'hanuman/page_bar'

  #before_filter       :authenticate_beta_user!
  
  #before_filter { |controller| controller.ssl_required if controller.permit?("#{SystemRoles::Admin} on CmsPage or #{SystemRoles::System}") }
  
  #------------------------------------------------------------------------------
  def index
    redirect_to "/#{DmCore::Language.locale}/index"
  end

  #------------------------------------------------------------------------------
  def show
    @current_page = CmsPage.find_by_slug(params[:slug])
    if @current_page.nil? || (!@current_page.is_published? && !is_admin?)
      render :action => :show, :layout => "cms_templates/404", :status => 404
      return
    end

    if @current_page.requires_login
      if !signed_in?
        redirect_to(main_app.new_user_session_url, :alert => 'You must be signed into your account before you can access this page') and return
      #elsif !current_user.is_beta?
      #  redirect_to(index_url, :alert => 'The Beta Program is currently limited - your application is waiting approval') and return
      end
    end

    case @current_page.pagetype
    when 'content'
      status = (@current_page.slug == 'missing' ? 404 : 200)
      content_for :page_title, @current_page.title
      #--- if body=true, then use a minimal template to render, suitable for a minimal iFrame
      if params['body'] == 'true'
        render :action => :show, :layout => "cms_templates/minimal_page", :status => status
      else
        render :action => :show, :layout => "cms_templates/#{@current_page.page_template}", :status => status
      end
    when 'pagelink'
      redirect_to showpage_url(:slug => @current_page.link)
    when 'controller/action'
      redirect_to "/#{DmCore::Language.locale}/#{@current_page.link}"
    when 'link'
      redirect_to @current_page.link
    when 'divider'
      render :text => 'Not a real page'
    end
  end
  
  # Basically empty, as well as the view.  But gets rendered by dm_core when the 
  # site is disabled
  #------------------------------------------------------------------------------
  def coming_soon
  end
end
