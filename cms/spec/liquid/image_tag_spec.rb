require 'spec_helper'

describe Liquid::Image, type: :liquid_tag do
  setup_account

  describe 'html rendering' do

    it 'just an image' do
      content = "{% image src : '/test_img.jpg' %}"
      arguments = nil
      doc = Liquid::Template.parse(content).render(arguments, filters: [LiquidFilters])
      expect(doc).to eq '<img src="/test_img.jpg" alt="Test img" />'
    end

    it 'with options (using size)' do
      content = "{% image src : '/test_img.jpg', class : ccc, title : ttt, size : 16x16, alt : aaa, style : sss, id : iii, mouseover : mmm %}"
      arguments = nil
      doc = Liquid::Template.parse(content).render(arguments, filters: [LiquidFilters])
      expect(doc).to eq '<img class="ccc" title="ttt" alt="aaa" style="sss" id="iii" mouseover="mmm" src="/test_img.jpg" width="16" height="16" />'
    end

    it 'with height and width' do
      content = "{% image src: '/test_img.jpg', width: 300, height: 200 %}"
      arguments = nil
      doc = Liquid::Template.parse(content).render(arguments, filters: [LiquidFilters])
      expect(doc).to eq '<img width="300" height="200" src="/test_img.jpg" alt="Test img" />'
    end
  end

  describe 'markdown rendering' do
    it 'just an image' do
      content = "{% image src : '/test_img.jpg' %}"
      arguments = nil
      doc = ::Kramdown::Document.new(Liquid::Template.parse(content).render(arguments, filters: [LiquidFilters]), parse_block_html: true)
      expect(doc.to_html.html_safe).to eq "<p><img src=\"/test_img.jpg\" alt=\"Test img\" /></p>\n"
    end
  end
end
