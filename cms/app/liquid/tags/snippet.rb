#------------------------------------------------------------------------------
module Liquid
  class Snippet < DmCore::LiquidTag
    include DmCore::AccountHelper
    include DmCore::LiquidHelper

    #------------------------------------------------------------------------------
    def render(context)
      output = ''
      if @attributes['slug'].present?
        cms_snippet = CmsSnippet.find_by_slug(@attributes['slug'])
        if cms_snippet
          output = context.registers[:view].render_content_item(cms_snippet)
        end
      end
      return output
    end

    #------------------------------------------------------------------------------
    def self.details
      { name: self.tag_name,
        summary: 'Display a snippet',
        category: 'structure',
        description: <<-END_OF_DESCRIPTION
Output the content of a snippet specified by the slug

~~~
{% snippet slug: 'some-snippet-slug'}
~~~

END_OF_DESCRIPTION
      }
    end
  end
  Template.register_tag('snippet', Snippet)
end
