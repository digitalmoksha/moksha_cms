module Liquid
  
  # Returns the path of an image in site assets, unless a full path is provided.
  #
  # {% image_path src : source_img %}
  #------------------------------------------------------------------------------
  class ImagePath < DmCore::LiquidTag
    include ActionView::Helpers::TagHelper 
    include ActionView::Helpers::AssetTagHelper
    include Sprockets::Helpers::RailsHelper
    include Sprockets::Helpers::IsolatedHelper
    include DmCore::UrlHelper

    #------------------------------------------------------------------------------
    def render(context)
      src = expand_url(@attributes["src"], "#{context.registers[:account_site_assets]}/images/")
      return src.nil? ? '' : src.html.safe
    end
  
    def self.details
      { name: self.tag_name,
        summary: 'Returns location of image',
        description: "Give the location/path of an image. Will pull image from the site's images directory unless a full path is given.",
        example: "{% image_path src: placeholder_190x105.jpg %}",
        category: 'image'
      }
    end
  end
  
  Template.register_tag('image_path', ImagePath)
end