module Liquid
  class UrlMedia < DmCore::LiquidTag
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::AssetTagHelper
    include DmCore::UrlHelper
    include DmCore::ParamsHelper

    #------------------------------------------------------------------------------
    def render(context)
      url = DmCms::MediaUrlService.call(@attributes['src'], version: @attributes['version'] || :original,
                                                            protected: @attributes['protected'].as_boolean)
      return url.nil? ? '' : url
    end

    def self.details
      { name: self.tag_name,
        summary: 'Returns url of a media file',
        category: 'url',
        description: <<-END_OF_DESCRIPTION
Give the location/url of a media file. It is relative to the site's media directory unless a full path/url is given.

~~~
{% url_media src: '2014/something.pdf' %}

{% url_media src: 'course/lesson1.mp3' %}

{% url_media src: 'nature/desert.jpg', version: 'retina_lg' %}

~~~
END_OF_DESCRIPTION
      }
    end
  end

  Template.register_tag('url_media',  UrlMedia)
  Template.register_tag('url_asset',  UrlMedia)  # TODO - DEPRECATED
  Template.register_tag('image_path', UrlMedia)  # TODO - DEPRECATED
  Template.register_tag('url_image',  UrlMedia)  # TODO - DEPRECATED
end