class DmCms::PagesController < DmCms::ApplicationController
  include ApplicationHelper
  include DmCore::UrlHelper
  include DmCore::LiquidHelper
  helper DmCms::RenderHelper
  helper DmCore::LiquidHelper
  
  #------------------------------------------------------------------------------
  def index
    redirect_to "/#{DmCore::Language.locale}/index"
  end

  #------------------------------------------------------------------------------
  def show
    render(file: 'public/404.html', status: :not_found, layout: false) && return if invalid_slug?

    #--- make sure we have a valid locale for this site set
    DmCore::Language.locale = current_account.verify_locale(params[:locale])
    
    #--- find the requested page, and if not found try to find the 'missing' page
    @current_page = CmsPage.friendly.find_by_slug(params[:slug])
    if @current_page.nil? || !can?(:read, @current_page)
      @current_page = CmsPage.friendly.find_by_slug('missing')
      render(file: 'public/404.html', status: :not_found, layout: false) && return if @current_page.nil? || !@current_page.is_published?
    end

    if @current_page.requires_login && !signed_in?
      redirect_to(main_app.new_user_session_url, alert: 'You must be signed into your account before you can access this page') and return
    end

    case @current_page.pagetype
    when 'content'
      status = (@current_page.slug == 'missing' ? 404 : 200)
      content_for :page_title, @current_page.title
      set_meta description: @current_page.summary, "og:description" => sanitize_text(markdown(@current_page.summary, safe: false))
      set_meta "og:image" => site_asset_media_url(@current_page.featured_image) if @current_page.featured_image.present?
      #--- if body=true, then use a minimal template to render, suitable for a minimal iFrame
      if params['body'] == 'true'
        render action: :show, layout: "cms_templates/minimal_page", status: status
      else
        render action: :show, layout: "cms_templates/#{@current_page.page_template}", status: status, formats: [:html]
      end
    when 'pagelink'
      redirect_to showpage_url(slug: @current_page.link)
    when 'controller/action'
      redirect_to "/#{DmCore::Language.locale}/#{@current_page.link}"
    when 'link'
      redirect_to @current_page.link
    when 'divider'
      render text: 'Not a real page'
    end
  end
  
  # Basically empty, as well as the view.  But gets rendered by dm_core when the 
  # site is disabled
  #------------------------------------------------------------------------------
  def coming_soon
  end

private

  # might get missing image requests, try to weed them out
  #------------------------------------------------------------------------------
  def invalid_slug?
    params[:slug].end_with?('.png', '.gif', '.jpg', '.mp4', '.mp3', '.ogg', '.avi', '.php', '.cgi')
  end
end
