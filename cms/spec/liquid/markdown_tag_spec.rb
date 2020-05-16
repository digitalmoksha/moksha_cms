require 'spec_helper'

describe Liquid::Markdown do
  describe 'markdown rendering' do
    it 'with markdown content' do
      content = "{% markdown %}# Test{% endmarkdown %}"
      doc = Liquid::Template.parse(content).render

      expect(doc).to eq "<h1 id=\"test\">Test</h1>\n"

      content = <<-CONTENT.strip_heredoc
        {% markdown %}
        # Test
        {% endmarkdown %}
      CONTENT
      doc = Liquid::Template.parse(content).render

      expect(doc).to eq "\n<h1 id=\"test\">Test</h1>\n\n"
    end
  end
end
