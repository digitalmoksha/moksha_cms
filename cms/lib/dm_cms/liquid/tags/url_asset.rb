module Liquid
  class UrlAsset < DmCore::LiquidTag
    include ActionView::Helpers::TagHelper 
    include ActionView::Helpers::AssetTagHelper
    include Sprockets::Helpers::RailsHelper
    include Sprockets::Helpers::IsolatedHelper
    include DmCore::UrlHelper

    #------------------------------------------------------------------------------
    def render(context)
      src = expand_url(@attributes["src"], "#{context.registers[:account_site_assets]}/")
      return src.nil? ? '' : src
    end
  
    def self.details
      { name: self.tag_name,
        summary: 'Returns url of an asset',
        description: "Give the location/url of an asset file. Is relative to the site's main asset directory unless a full path/url is given.",
        example: "{% url_asset src: 'library/something.pdf' %}",
        category: 'url'
      }
    end
  end
  
  Template.register_tag('url_asset', UrlAsset)
end