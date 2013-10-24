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
        description: "Outpus an HTML 'div' block.  You can specify id, class, and style.  You can also specify the markdown modifier, such as 'markdown: 0'",
        example: self.example,
        category: 'structure'
      }
    end
    def self.example
      example = <<-END_OF_STRING
{% div id: some_id, class: some_class, style: some_style %}
...content
{% enddiv %}
END_OF_STRING
    end
  end

  Template.register_tag('div', Div)
  
end