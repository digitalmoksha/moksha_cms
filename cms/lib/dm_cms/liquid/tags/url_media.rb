module Liquid
  class UrlMedia < DmCore::LiquidTag
    include ActionView::Helpers::TagHelper 
    include ActionView::Helpers::AssetTagHelper
    include DmCore::UrlHelper
    include DmCore::ParamsHelper
    include DmCore::AccountHelper

    #------------------------------------------------------------------------------
    def render(context)
      if @attributes['version']
        #--- pull from MediaFile object
        src = MediaFile.url_by_name(@attributes['src'], version: @attributes['version'])
      else
        #--- handle like regular url
        src = file_url(@attributes['src'], account_site_assets: context_account_site_assets(context), default_folder: 'media', protected: @attributes['protected'].as_boolean)
      end
      return src.nil? ? '' : src
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
  
  Template.register_tag('url_media', UrlMedia)
end