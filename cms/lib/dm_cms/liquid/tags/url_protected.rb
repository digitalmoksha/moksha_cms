module Liquid
  class UrlProtected < DmCore::LiquidTag
    include ActionView::Helpers::TagHelper 
    include ActionView::Helpers::AssetTagHelper
    # include Sprockets::Rails::Helper
    include DmCore::UrlHelper
    include DmCore::ParamsHelper
    include DmCore::AccountHelper

    #------------------------------------------------------------------------------
    def render(context)
      src = file_url(@attributes["src"], account_site_assets: context_account_site_assets(context), default_folder: '', protected: true)
      return src.nil? ? '' : src
    end
  
    def self.details
      { name: self.tag_name,
        summary: 'Returns url of a protected asset',
        category: 'url',
        description: <<-END_OF_DESCRIPTION
Give the location/url of a protected asset file.

~~~
{% url_protected src: 'teachers/something.pdf' %}
~~~
END_OF_DESCRIPTION
      }
    end
  end
  
  Template.register_tag('url_protected', UrlProtected)
end