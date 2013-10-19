#------------------------------------------------------------------------------
class DmNewsletter::Admin::ApplicationController < DmCore::Admin::AdminController
  include DmNewsletter::NewslettersHelper
  helper  'dm_newsletter/newsletters'
end
