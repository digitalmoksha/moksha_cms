# Subclass from main ApplicationController, which will subclass from DmCore
#------------------------------------------------------------------------------
class DmCms::ApplicationController < ::ApplicationController
  include ApplicationHelper
  helper DmCms::RenderHelper
  helper DmCore::LiquidHelper
  helper DmCore::AccountHelper
  include DmCore::AccountHelper
end
