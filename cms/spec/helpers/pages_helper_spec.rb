require 'spec_helper'

include DmCms::PagesHelper

describe DmCms::PagesHelper do
  setup_account

  describe '#redirect_link' do
    #------------------------------------------------------------------------------
    it 'returns nil if no link specified' do
      expect(redirect_link('')).to eq nil
    end

    #------------------------------------------------------------------------------
    it 'redirects to an internal slug (pagelink)' do
      link = 'test-page'
      expect(redirect_link(link)).to eq 'http://test.example.com/en/test-page'
    end

    #------------------------------------------------------------------------------
    it 'redirects to a relative page' do
      link = 'some/test/path'
      expect(redirect_link(link)).to eq 'http://test.example.com/en/some/test/path'
    end

    #------------------------------------------------------------------------------
    it 'redirects to an absolute page on the site' do
      link = '/some/other/path'
      expect(redirect_link(link)).to eq 'http://test.example.com/en/some/other/path'
    end

    #------------------------------------------------------------------------------
    it 'redirects to an external link' do
      link = 'https://another.example.com/test-page-2'
      expect(redirect_link(link)).to eq 'https://another.example.com/test-page-2'
    end
  end

  describe '#page_link' do
    #------------------------------------------------------------------------------
    it 'redirects to an internal slug' do
      page = create(:page, menutitle: 'Go Here')
      expect(page_link(page)).to eq '<a href="http://test.example.com/en/test-page">Go Here</a>'
      expect(page_link(page, 'No Go Here')).to eq '<a href="http://test.example.com/en/test-page">No Go Here</a>'
    end

    #------------------------------------------------------------------------------
    it 'redirects to a relative page' do
      page = create(:page_internal_pagelink, link: 'some/test/path', menutitle: 'Go Here')
      expect(page_link(page)).to eq '<a href="http://test.example.com/en/some/test/path">Go Here</a>'
      expect(page_link(page, 'No Go Here')).to eq '<a href="http://test.example.com/en/some/test/path">No Go Here</a>'
    end

    #------------------------------------------------------------------------------
    it 'redirects to an external page and opens in another window' do
      page = create(:page_external_link_new_window, menutitle: 'Go Here')
      expect(page_link(page)).to eq '<a target="_blank" href="http://another.example.com/en/test-page">Go Here</a>'
    end

  end
  
  it '#page_url'
  it '#content_by_name'
  it '#content_by_name?'
  it '#snippet'
  it '#snippet?'
  it '#render_content_item'
  it '#main_menu'
  it '#menu_from_pages'
  it '#menu_from_pages_bs3'
  it '#allow_page_in_menu?'
  it '#main_menu_select'
  it '#page_authorized?'
  it '#current_page?'
  it '#current_page_path?'
  it '#page_in_section?'

end