module DmCms
  module Liquid
    module Tags
      class Markdown < DmCore::LiquidBlock
        include DmCore::LiquidHelper

        #------------------------------------------------------------------------------
        def render(context)
          markdown(super, safe: false)
        end

        def self.details
          {
            name: tag_name,
            summary: 'Process text with Markdown',
            category: 'structure',
            description: description
          }
        end

        #------------------------------------------------------------------------------
        def self.description
          <<-DESCRIPTION.strip_heredoc
          Process the enclosed text with Markdown. Useful when your processing a page as HTML, but you would like to use
          Markdown in certain sections.
    
          ~~~
          {% markdown %}
            ...content
          {% endmarkdown %}
          ~~~
          DESCRIPTION
        end
      end
    end
  end

  ::Liquid::Template.register_tag('markdown', Liquid::Tags::Markdown)
end
