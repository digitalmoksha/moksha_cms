module Liquid
  class Markdown < DmCore::LiquidBlock
    include DmCore::LiquidHelper
    
    #------------------------------------------------------------------------------
    def render(context)
      markdown(super, safe: false)
    end

    def self.details
      { name: self.tag_name,
        summary: 'Process text with Markdown',
        category: 'structure',
        description: <<-END_OF_DESCRIPTION
Process the enclosed text with Markdown. Useful when your processing a page as HTML, but you would like to use
Markdown in certain sections.

~~~
{% markdown %}
  ...content
{% endmarkdown %}
~~~
END_OF_DESCRIPTION
      }
    end
  end

  Template.register_tag('markdown', Markdown)
  
end