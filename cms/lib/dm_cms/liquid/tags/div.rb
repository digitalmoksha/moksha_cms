module Liquid
  # {% video_frame width : 720, caption : 'some caption', class : some_class
  #          title: 'some_title', :id : some_id, alt : alt_text, side : right %}
  #------------------------------------------------------------------------------
  class Div < DmCore::LiquidBlock

    # width defaults to 720.  Best supported widths are 150, 220, 340, 720, 940
    #------------------------------------------------------------------------------
    def render(context)
      @attributes.reverse_merge!  'class' =>  '', 'id' => '', 'style' => ''

      output  = super
      content = RedCloth.new(output.strip).to_html.html_safe
      style   = "style='#{@attributes["style"]}'" unless @attributes['style'].blank?
      dclass  = "class='#{@attributes["class"]}'" unless @attributes['class'].blank?
      id      = "id='#{@attributes["id"]}'" unless @attributes['id'].blank?
      
      out += "<notextile><div #{[id, dclass, style].join(' ')}>"
      out += content
      out += "</div></notextile>"
    end

    def self.details
      { name: self.tag_name,
        summary: 'HTML div block',
        description: "Outpus an HTML 'div' block.  You can specify id, class, and style.",
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