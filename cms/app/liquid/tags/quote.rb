module Liquid
  class Quote < DmCore::LiquidBlock
    #------------------------------------------------------------------------------
    def render(context)
      @attributes.reverse_merge! 'class' => '', 'id' => '', 'style' => '', 'author' => ''

      output  = super
      style   = "style='#{@attributes["style"]}'" unless @attributes['style'].blank?
      dclass  = "class='#{@attributes["class"]}'" unless @attributes['class'].blank?
      id      = "id='#{@attributes["id"]}'" unless @attributes['id'].blank?

      out  = "<blockquote #{[id, dclass, style].join(' ')}>"
      out += output
      out += "\r\n<footer markdown='0'><cite>#{@attributes['author']}</cite></footer>" unless @attributes['author'].blank?
      out += "</blockquote>"
    end

    def self.details
      { name: self.tag_name,
        summary: 'HTML blockquote',
        category: 'structure',
        description: <<-END_OF_DESCRIPTION
Outpus an HTML 'blockquote' with optional author.  You can specify id, class, and style.

~~~
{% quote author: 'Favorite Person', id: some_id, class: some_class, style: some_style %}
  ...content
{% endquote %}
~~~
END_OF_DESCRIPTION
      }
    end
  end

  Template.register_tag('quote', Quote)
end