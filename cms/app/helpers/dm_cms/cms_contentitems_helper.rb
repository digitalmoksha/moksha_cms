module DmCms::CmsContentitemsHelper

  # return a select list of the different content types
  #------------------------------------------------------------------------------
  def select_content_type(object = "cms_contentitem")
    select(object, 'itemtype', CmsContentitem::CONTENT_TYPES)
  end
end
