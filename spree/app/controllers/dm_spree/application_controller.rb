# Subclass from main ApplicationController, which will subclass from DmCore
#------------------------------------------------------------------------------
class DmSpree::ApplicationController < ::ApplicationController
  include ApplicationHelper  

  #--- these are needed to support rendering layouts built for the CMS
  helper    DmCms::RenderHelper
  helper    DmCore::LiquidHelper
  helper    DmCms::PagesHelper
  include   DmCore::RenderHelper

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  
private

  #------------------------------------------------------------------------------
  def record_not_found
    flash[:error] = "The item you were looking for could not be found."
    redirect_to spree_root_path
  end
end
