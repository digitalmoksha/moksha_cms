# Simple div tag
#
# {% div id: some_id, class: "class1 class2", style: "color: red; background-color: #aaa;" %}
# ...content
# {% enddiv %}
#------------------------------------------------------------------------------
module DmCms
  module Liquid
    module Tags
      class Div < DmCore::LiquidBlock
        include ActionView::Helpers::TagHelper

        #------------------------------------------------------------------------------
        def render(context)
          @attributes.symbolize_keys!
          @attributes[:markdown] = (@attributes[:markdown].as_boolean ? 1 : 0) if @attributes[:markdown]

          content = super
          content_tag :div, content, @attributes, false
        end

        #------------------------------------------------------------------------------
        def self.details
          {
            name: tag_name,
            summary: 'HTML div block',
            category: 'structure',
            description: description
          }
        end

        #------------------------------------------------------------------------------
        def self.description
          <<-DESCRIPTION.strip_heredoc
          Outputs an HTML 'div' block.  You can specify id, class, and style.
          You can also specify the markdown modifier, such as 'markdown: 0', if you don't wish the contents to be
          processed by Markdown.
    
          ~~~
          {% div id: some_id, class: "class1 class2", style: "color: red; background-color: #aaa;" %}
          ...content
          {% enddiv %}
          ~~~
    
          _Note:_ `class` and `style` are specified the same as a normal HTML div
          DESCRIPTION
        end
      end
    end
  end

  ::Liquid::Template.register_tag('div', Liquid::Tags::Div)
end
