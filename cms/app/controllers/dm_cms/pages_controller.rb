class DmCms::PagesController < DmCms::ApplicationController
  include ApplicationHelper  
  helper DmCms::RenderHelper
  helper DmCore::LiquidHelper
  
  #------------------------------------------------------------------------------
  def index
    redirect_to "/#{DmCore::Language.locale}/index"
  end

  #------------------------------------------------------------------------------
  def show
    #--- might get missing image requests, try to weed them out
    render(:file => 'public/404.html', :status => :not_found, :layout => false) && return if ['png', 'gif', 'jpg', 'mp4', 'mp3', 'ogg', 'avi', 'php', 'cgi'].include? params[:format]

    #--- make sure we have a valid locale for this site set
    DmCore::Language.locale = current_account.verify_locale(params[:locale])
    
    #--- find the requested page, and if not found try to find the 'missing' page
    @current_page = CmsPage.friendly.find(params[:slug])
    if @current_page.nil? || (!@current_page.is_published? && !is_admin?)
      @current_page = CmsPage.find_by_slug('missing')
      render :action => :show, :layout => "cms_templates/404", :status => 404 && return if @current_page.nil?
    end

    if @current_page.requires_login
      if !signed_in?
        redirect_to(main_app.new_user_session_url, :alert => 'You must be signed into your account before you can access this page') and return
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
        render :action => :show, :layout => "cms_templates/#{@current_page.page_template}", :status => status, :formats => [:html]
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
