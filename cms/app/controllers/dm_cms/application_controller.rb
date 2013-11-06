# Subclass from main ApplicationController, which will subclass from DmCore
#------------------------------------------------------------------------------
class DmCms::ApplicationController < ::ApplicationController
  include ApplicationHelper
  helper DmCms::RenderHelper
  helper DmCms::AnalyticsHelper
  helper DmCore::LiquidHelper
end
