#------------------------------------------------------------------------------
class DmForum::Admin::ForumSitesController < DmForum::Admin::ApplicationController

  before_filter   :forum_site_lookup

  # GET /admin/fms/forum_site
  #------------------------------------------------------------------------------
  def show
    unless @forum_site
      @forum_site = ForumSite.create(enabled: false)
    end
  end


  # GET /admin/fms/forum_site/edit
  #------------------------------------------------------------------------------
  def edit
  end

  # PUT /admin/fms/forum_site
  #------------------------------------------------------------------------------
  def update
    if @forum_site.update_attributes(params[:forum_site])
      redirect_to dm_forum.admin_forum_site_url, notice: "Forum settings were successfully updated."
    else
      render action: :edit
    end
  end

private

  #------------------------------------------------------------------------------
  def forum_site_lookup
    @forum_site = ForumSite.site
  end

end
