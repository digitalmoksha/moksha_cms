module Liquid
  class UrlAsset < DmCore::LiquidTag
    include ActionView::Helpers::TagHelper 
    include ActionView::Helpers::AssetTagHelper
    include Sprockets::Helpers::RailsHelper
    include Sprockets::Helpers::IsolatedHelper
    include DmCore::UrlHelper
    include DmCore::ParamsHelper
    include DmCore::AccountHelper

    #------------------------------------------------------------------------------
    def render(context)
      src = file_url(@attributes["src"], account_site_assets: context_account_site_assets(context), default_folder: '', protected: @attributes['protected'].as_boolean)
      return src.nil? ? '' : src
    end
  
    def self.details
      { name: self.tag_name,
        summary: 'Returns url of an asset',
        category: 'url',
        description: <<-END_OF_DESCRIPTION
Give the location/url of an asset file. Is relative to the site's main asset directory unless a full path/url is given.

~~~
{% url_asset src: 'library/something.pdf' %}
~~~
END_OF_DESCRIPTION
      }
    end
  end
  
  Template.register_tag('url_asset', UrlAsset)
end