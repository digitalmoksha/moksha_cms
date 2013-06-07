module Liquid
  
  # Simple image tag - uses rails helper 
  #
  # {% image src : source_img, class : ccc, title : ttt, size : 16x16, width : www, height : hhh, alt : aaa, style : sss, id : iii,
  #          mouseover : mmm}
  #------------------------------------------------------------------------------
  class Image < DmCore::LiquidTag
    include ActionView::Helpers::TagHelper 
    include ActionView::Helpers::AssetTagHelper
    include Sprockets::Helpers::RailsHelper
    include Sprockets::Helpers::IsolatedHelper
    include DmCore::UrlHelper

    #------------------------------------------------------------------------------
    def render(context)
      @attributes.reverse_merge!  'alt' =>  ''
      src       = file_path(@attributes["src"], context)
      mouseover = file_path(@attributes["mouseover"], context)

      image_tag(src,  class: @attributes["class"], title: @attributes["title"], size: @attributes["size"], 
                      width: @attributes["width"], height: @attributes["height"], alt: @attributes["alt"],
                      style: @attributes["style"], id: @attributes["id"], mouseover: mouseover)
    end
  
    #------------------------------------------------------------------------------
    def file_path(file_name, context)
      if @attributes['protected'] == 'true' || @attributes['protected'] == 'yes' || @attributes['protected'] == '1'
        expand_url(file_name, "/protected_asset/")
      else
        expand_url(file_name, "#{context.registers[:account_site_assets]}/images/")
      end
    end
    
    def self.details
      { name: self.tag_name,
        summary: 'Displays an image',
        description: "Displays an image. Will pull image from the site's images directory unless a full path is given.  All attributes are optional except <code>src</code>",
        example: self.example,
        category: 'image'
      }
    end

    def self.example
      example = <<-END_OF_STRING
{% image src: placeholder_190x105.jpg, class: right, protected: true,
       title: "Some title", size: 16x16, width: www, 
       height: hhh, alt: "Alt text",
       style : sss, id : iii, mouseover : mmm %}
END_OF_STRING
    end
  end
  
  Template.register_tag('image', Image)
end