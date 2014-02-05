# Returns the path of an image in site assets, unless a full path is provided.
#
# {% image_path src : source_img %}
#------------------------------------------------------------------------------
module Liquid  
  class UrlImage < DmCore::LiquidTag
    include ActionView::Helpers::TagHelper 
    include ActionView::Helpers::AssetTagHelper
    include Sprockets::Helpers::RailsHelper
    include Sprockets::Helpers::IsolatedHelper
    include DmCore::UrlHelper
    include DmCore::ParamsHelper
    include DmCore::AccountHelper

    #------------------------------------------------------------------------------
    def render(context)
      src = file_url(@attributes["src"], account_site_assets: context_account_site_assets(context), default_folder: 'images', protected: @attributes['protected'].as_boolean)
      return src.nil? ? '' : src
    end
  
    def self.details
      { name: self.tag_name,
        summary: 'Returns location of image',
        category: 'image',
        description: <<-END_OF_DESCRIPTION
Give the location/path of an image. Will pull image from the site's images directory unless a full path is given.

~~~
{% url_image src: placeholder_190x105.jpg %}
~~~
END_OF_DESCRIPTION
      }
    end
  end
  
  Template.register_tag('image_path', UrlImage)
  Template.register_tag('url_image', UrlImage)
end