module Liquid
  
  #------------------------------------------------------------------------------
  class UrlProtected < DmCore::LiquidTag
    include ActionView::Helpers::TagHelper 
    include ActionView::Helpers::AssetTagHelper
    include Sprockets::Helpers::RailsHelper
    include Sprockets::Helpers::IsolatedHelper
    include DmCore::UrlHelper

    #------------------------------------------------------------------------------
    def render(context)
      src = expand_url(@attributes["src"], "/protected_asset/")
      return src.nil? ? '' : src
    end
  
    def self.details
      { name: self.tag_name,
        summary: 'Returns url of a protected asset',
        description: "Give the location/url of a protected asset file.",
        example: "{% url_protected src: 'teachers/something.pdf' %}",
        category: 'url'
      }
    end
  end
  
  Template.register_tag('url_protected', UrlProtected)
end