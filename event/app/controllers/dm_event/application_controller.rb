# Subclass from main ApplicationController, which will subclass from DmCore
#------------------------------------------------------------------------------
class DmEvent::ApplicationController < ::ApplicationController
  include ApplicationHelper

  #--- these are needed to support rendering layouts built for the CMS
  helper    DmCms::RenderHelper
  helper    DmCore::LiquidHelper
  helper    DmCms::PagesHelper
  include   DmCore::RenderHelper

  # before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  #------------------------------------------------------------------------------
  def record_not_found
    flash[:error] = "The event or registration you were looking for could not be found."
    redirect_to event_root_path
  end
end
