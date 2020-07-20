class DmCms::Admin::CmsSnippetsController < DmCms::Admin::AdminController
  include DmCms::PermittedParams

  before_action   :find_snippet, except: [:index, :new, :create]
  before_action   :set_title

  include DmCore::LiquidHelper

  #------------------------------------------------------------------------------
  def index
    @cms_snippets = CmsSnippet.order('slug ASC')
  end

  #------------------------------------------------------------------------------
  def new
    @cms_snippet = CmsSnippet.new
  end

  #------------------------------------------------------------------------------
  def create
    @cms_snippet = CmsSnippet.new(cms_snippet_params)
    if @cms_snippet.save
      redirect_to admin_cms_snippets_url, notice: 'Snippet successfully created.'
    else
      render action: :new
    end
  end

  #------------------------------------------------------------------------------
  def edit; end

  #------------------------------------------------------------------------------
  def update
    if @cms_snippet.update(cms_snippet_params)
      redirect_to admin_cms_snippets_url, notice: 'Content updated'
    else
      render action: :edit, alert: 'An error of some kind occurred'
    end
  end

  #------------------------------------------------------------------------------
  def destroy
    @cms_snippet.destroy
    redirect_to admin_cms_snippets_url
  end

  # [todo]
  #------------------------------------------------------------------------------
  def update_fragment
    if @cms_snippet.update(cms_snippet_params)
      # @cms_page.merge!(@item.cms_page.get_page_render_values)
      # respond_to do |format|
      #  format.js { render :action => :update_fragment }
      # end
    end
  end

  private

  #------------------------------------------------------------------------------
  def find_snippet
    @cms_snippet = CmsSnippet.friendly.find(params[:id])
  end

  # Set some values for the template based on the controller
  #------------------------------------------------------------------------------
  def set_title
    text = 'Snippets'
    content_for :content_title, text
  end
end
