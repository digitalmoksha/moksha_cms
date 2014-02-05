# Simple image tag - uses rails helper 
#
# {% image src : source_img, class : ccc, title : ttt, size : 16x16, width : www, height : hhh,
#          alt : aaa, style : sss, id : iii, mouseover : mmm}
#------------------------------------------------------------------------------
module Liquid
  class Image < DmCore::LiquidTag
    include ActionView::Helpers::TagHelper 
    include ActionView::Helpers::AssetTagHelper
    include Sprockets::Helpers::RailsHelper
    include Sprockets::Helpers::IsolatedHelper
    include DmCore::UrlHelper
    include DmCore::ParamsHelper
    include DmCore::AccountHelper

    #------------------------------------------------------------------------------
    def render(context)
      @attributes.reverse_merge!  'alt' =>  ''
      src       = file_url(@attributes["src"], account_site_assets: context_account_site_assets(context), default_folder: 'images', protected: @attributes['protected'].as_boolean)

      image_tag(src,  class: @attributes["class"], title: @attributes["title"], size: @attributes["size"], 
                      width: @attributes["width"], height: @attributes["height"], alt: @attributes["alt"],
                      style: @attributes["style"], id: @attributes["id"])
    end
  
    #------------------------------------------------------------------------------
    def self.details
      { name: self.tag_name,
        summary: 'Displays an image',
        category: 'image',
        description: <<-END_OF_DESCRIPTION
Displays an image. Will pull image from the site's images directory unless a full path is given.
All attributes are optional except `src`

~~~
{% image src: placeholder_190x105.jpg, class: right, protected: true,
       title: "Some title", size: 16x16, width: www, 
       height: hhh, alt: "Alt text",
       style : sss, id : iii %}
~~~
END_OF_DESCRIPTION
      }
    end
  end
  
  Template.register_tag('image', Image)
end