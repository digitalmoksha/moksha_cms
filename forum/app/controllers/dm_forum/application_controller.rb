class DmForum::ApplicationController < DmCore::ApplicationController
  include ApplicationHelper  

  #--- these are needed to support rendering layouts built for the CMS
  helper    DmCms::RenderHelper
  helper    DmCore::LiquidHelper
  helper    DmCms::PagesHelper
  include   DmCore::RenderHelper

  #before_filter :authenticate_user!

  layout    'forum_templates/forum_list'

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  
private

  #------------------------------------------------------------------------------
  def record_not_found
    flash[:error] = "The forum or discussion you were looking for could not be found."
    redirect_to forum_root_path
  end
end
