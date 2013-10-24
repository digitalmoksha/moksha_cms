module Liquid
  class Quote < DmCore::LiquidBlock

    #------------------------------------------------------------------------------
    def render(context)
      @attributes.reverse_merge!  'class' => '', 'id' => '', 'style' => '', 'author' => '', 'dash' => true

      output  = super
      style   = "style='#{@attributes["style"]}'" unless @attributes['style'].blank?
      dclass  = "class='#{@attributes["class"]}'" unless @attributes['class'].blank?
      id      = "id='#{@attributes["id"]}'" unless @attributes['id'].blank?
      
      out  = "<blockquote #{[id, dclass, style].join(' ')}>"
      out += output
      out += "<footer markdown='0'>#{'&mdash; ' if @attributes['dash']}#{@attributes['author']}</footer>" unless @attributes['author'].blank?
      out += "</blockquote>"
    end

    def self.details
      { name: self.tag_name,
        summary: 'HTML blockquote',
        description: "Outpus an HTML 'blockquote' with optional author.  You can specify id, class, and style.  Specify 'dash: false' to remove the dash on the authors name.",
        example: self.example,
        category: 'structure'
      }
    end
    def self.example
      example = <<-END_OF_STRING
{% quote author: 'Favorite Person', id: some_id, class: some_class, style: some_style, dash: false %}
...content
{% endquote %}
END_OF_STRING
    end
  end

  Template.register_tag('quote', Quote)
  
end