class DmCms::PagesController < DmCms::ApplicationController
  include ApplicationHelper
  include DmCore::UrlHelper
  include DmCore::LiquidHelper
  helper DmCms::RenderHelper
  helper DmCore::LiquidHelper

  #------------------------------------------------------------------------------
  def show
    respond_to do |format|
      format.html do
        #--- make sure we have a valid locale for this site set
        DmCore::Language.locale = current_account.verify_locale(params[:locale])

        #--- find the requested page, and if not found try to find the 'missing' page
        @current_page = CmsPage.friendly.find_by_slug(params[:slug])
        if @current_page.nil? || !can?(:read, @current_page)
          @current_page = CmsPage.friendly.find_by_slug('missing')
          render(file: Rails.root.join('public', '404.html'), status: :not_found, layout: false) && return if @current_page.nil? || !@current_page.is_published?
        end

        raise Account::LoginRequired, I18n.t('cms.page_login_required') if @current_page.requires_login && !signed_in?

        if @current_page.redirect_page?
          redirect_to helpers.redirect_link(@current_page.link)
        elsif @current_page.divider?
          render plain: 'Not a real page'
        else
          # content page
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
        end
      end
      format.any { head :not_found }
    end
  end

  # Basically empty, as well as the view.  But gets rendered by dm_core when the
  # site is disabled
  #------------------------------------------------------------------------------
  def coming_soon; end
end
