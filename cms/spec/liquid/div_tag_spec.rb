require 'spec_helper'

describe Liquid::Div do

  describe 'html rendering' do
    it 'with no options' do
      content = "{% div %}<h1>Test</h1>{% enddiv %}"
      arguments = nil
      doc = Liquid::Template.parse(content).render(arguments, filters: [LiquidFilters])
      expect(doc).to eq '<div><h1>Test</h1></div>'
    end

    it 'with class, style, and id' do
      content = "{% div class: 'wide shadow', style: 'text: align-left', id: 'my_id' %}<h1>Test</h1>{% enddiv %}"
      arguments = nil
      doc = Liquid::Template.parse(content).render(arguments, filters: [LiquidFilters])
      expect(doc).to eq '<div class="wide shadow" style="text: align-left" id="my_id"><h1>Test</h1></div>'
    end
  end

  describe 'markdown rendering' do
    it 'with no options' do
      content = "{% div %}<h1>Test</h1>{% enddiv %}"
      arguments = nil
      doc = ::Kramdown::Document.new(Liquid::Template.parse(content).render(arguments, filters: [LiquidFilters]))
      expect(doc.to_html.html_safe).to eq "<div><h1>Test</h1></div>\n"
    end

    it 'with markdown content' do
      content = <<-END_OF_CONTENT
{% div %}
# Test
{% enddiv %}
END_OF_CONTENT
      arguments = nil
      doc = ::Kramdown::Document.new(Liquid::Template.parse(content).render(arguments, filters: [LiquidFilters]), parse_block_html: true)
      expect(doc.to_html.html_safe).to eq <<-END_OF_RESULT
<div>
  <h1 id="test">Test</h1>
</div>
END_OF_RESULT
    end

    it 'with markdown turned off' do
      content = "{% div markdown: false %}# Test{% enddiv %}"
      arguments = nil
      doc = ::Kramdown::Document.new(Liquid::Template.parse(content).render(arguments, filters: [LiquidFilters]), parse_block_html: true)
      expect(doc.to_html.html_safe).to eq "<div># Test</div>\n"
    end
  end
end
