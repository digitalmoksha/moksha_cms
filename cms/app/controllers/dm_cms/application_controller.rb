class DmCms::ApplicationController < DmCore::ApplicationController
  include ApplicationHelper
  helper DmCms::RenderHelper
  helper DmCore::LiquidHelper
end
