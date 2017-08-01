# Simple image tag - uses rails helper 
#
# {% image src : source_img, class : ccc, title : ttt, size : 16x16, width : www, height : hhh,
#          alt : aaa, style : sss, id : iii, mouseover : mmm}
#------------------------------------------------------------------------------
module Liquid
  class Image < DmCore::LiquidTag
    include ActionView::Helpers::TagHelper 
    include ActionView::Helpers::AssetTagHelper
    include DmCore::UrlHelper
    include DmCore::ParamsHelper
    include DmCore::AccountHelper

    #------------------------------------------------------------------------------
    def render(context)
      src     = @attributes.delete('src')
      version = @attributes.delete('version')
      protect = @attributes.delete('protected').as_boolean
      if version
        #--- pull from MediaFile object
        url = MediaFile.url_by_name(src, version: version)
      else
        #--- handle like regular url
        url = file_url(src, base: context_account_site_assets_media(context), protected: protect)
      end
      image_tag(url,  @attributes)
    end
  
    #------------------------------------------------------------------------------
    def self.details
      { name: self.tag_name,
        summary: 'Displays an image',
        category: 'media',
        description: <<-END_OF_DESCRIPTION
Displays an image. Will pull image (with optional version) from the site's media directory unless a full path is given.
Any normal HTML img attributes can be passed, such `alt`, `title`, `width`, etc

Parameters:

src
: name of the image.  Can either reference a file in the 'media' directory (`2014/car.jpg`), a full path (`http://example.com/image/car.jpg`)
or reference an S3 file (`s3://bucket/car.jpg`)

version
: (optional) Use a specific image version (`thumb`, `lg`, etc)

protected
: (optional) File is in protected directory.  `version` will have no effect with this option

html img attributes
: you can specify any valid HTML img attributes, such as `width` or `title`

**Examples**

~~~
{% image src: '2014/placeholder_190x105.jpg', class: 'right', title: "Some title" %}
~~~
Image in the media directory, with a specified class and title

~~~
{% image src: '2014/placeholder_190x105.jpg', class: right, protected: true %}
~~~
Image is in the protected asset folder

~~~
{% image src: '2014/placeholder_190x105.jpg', version: 'thumb', alt: "Some title" %}
~~~
Use the `thumb` version of the image

END_OF_DESCRIPTION
      }
    end
  end
  
  Template.register_tag('image', Image)
end