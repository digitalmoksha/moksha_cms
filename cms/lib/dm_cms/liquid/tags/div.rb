module Liquid
  class Div < DmCore::LiquidBlock

    #------------------------------------------------------------------------------
    def render(context)
      @attributes.reverse_merge!  'class' =>  '', 'id' => '', 'style' => '', 'markdown' => ''

      output    = super
      style     = "style='#{@attributes["style"]}'" unless @attributes['style'].blank?
      dclass    = "class='#{@attributes["class"]}'" unless @attributes['class'].blank?
      id        = "id='#{@attributes["id"]}'" unless @attributes['id'].blank?
      markdown  = "markdown='#{@attributes["markdown"]}'" unless @attributes['markdown'].blank?
      
      out  = "<div #{[id, dclass, style, markdown].join(' ')}>"
      out += output
      out += "</div>"
    end

    def self.details
      { name: self.tag_name,
        summary: 'HTML div block',
        category: 'structure',
        description: <<-END_OF_DESCRIPTION
Outputs an HTML 'div' block.  You can specify id, class, and style.
You can also specify the markdown modifier, such as 'markdown: 0', if you don't wish the contents to be 
processed by Markdown.

~~~
{% div id: some_id, class: "class1 class2", style: "color: red; background-color: #aaa;" %}
...content
{% enddiv %}
~~~

_Note:_ `class` and `style` are specified the same as a normal HTML div
END_OF_DESCRIPTION
      }
    end
  end

  Template.register_tag('div', Div)
  
end