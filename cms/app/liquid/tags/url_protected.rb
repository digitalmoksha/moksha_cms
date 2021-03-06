module Liquid
  class UrlProtected < DmCore::LiquidTag
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::AssetTagHelper
    include DmCore::UrlHelper
    include DmCore::ParamsHelper

    #------------------------------------------------------------------------------
    def render(context)
      url = DmCms::MediaUrlService.call(@attributes['src'], protected: true)
      url.nil? ? '' : url
    end

    def self.details
      {
        name: tag_name,
        summary: 'Returns url of a protected asset',
        category: 'url',
        description: description
      }
    end

    #------------------------------------------------------------------------------
    def self.description
      <<-DESCRIPTION.strip_heredoc
      Give the location/url of a protected asset file.

      ~~~
      {% url_protected src: 'teachers/something.pdf' %}
      ~~~
      DESCRIPTION
    end
  end

  Template.register_tag('url_protected', UrlProtected)
end
