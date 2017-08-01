# DEPRECATED - use url_media instead
#------------------------------------------------------------------------------
module Liquid
  class UrlAsset < DmCore::LiquidTag
    include ActionView::Helpers::TagHelper 
    include ActionView::Helpers::AssetTagHelper
    include DmCore::UrlHelper
    include DmCore::ParamsHelper
    include DmCore::AccountHelper

    #------------------------------------------------------------------------------
    def render(context)
      if @attributes['version']
        #--- pull from MediaFile object
        src = MediaFile.url_by_name(@attributes['src'], version: @attributes['version'])
      else
        #--- handle like regular url
        src = file_url(@attributes['src'], base: context_account_site_assets_media(context), protected: @attributes['protected'].as_boolean)
      end
      return src.nil? ? '' : src
    end
  
#     def self.details
#       { name: self.tag_name,
#         summary: 'Returns url of an asset',
#         category: 'url',
#         description: <<-END_OF_DESCRIPTION
# Give the location/url of an asset file. It is relative to the site's media directory unless a full path/url is given.
# 
# ~~~
# {% url_asset src: 'library/something.pdf' %}
# ~~~
# END_OF_DESCRIPTION
#       }
#     end
  end
  
  Template.register_tag('url_asset',  UrlAsset)
  Template.register_tag('image_path', UrlAsset)
  Template.register_tag('url_image',  UrlAsset)
end