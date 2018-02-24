require 'spec_helper'

include DmCore::ApplicationHelper
include DmCms::PagesHelper

describe DmCms::PagesHelper, type: :helper do
  helper do
    def user_signed_in?
      user.present?
    end
  end

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

  # x = main_menu(class: 'sf-menu', include_home: true, sub_menu_1: 'sub-menu', sub_menu_2: 'sub-menu third-menu')
  describe '#main_menu' do
    let(:user)  { nil }
    let!(:root) { CmsPage.create(slug: 'index', template: 'index', published: true, title: 'Front Page', menutitle: 'Home') }

    it 'returns nothing if there are no pages' do
      expect(main_menu).to eq ''
    end

    it 'returns nothing if nothing published' do
      root.update_attribute(:published, false)
      root.children.create(slug: 'top1', published: false, title: 'Top Level 1')

      expect(main_menu).to eq ''
    end

    it 'returns root page' do
      expect(main_menu(include_home: true)).to eq "<ul ><li><a href=\"http://test.example.com/en/index\">Home</a></li></ul>"
    end

    it 'does not return root page if menutitle is empty' do
      root.update_attribute(:menutitle, nil)

      expect(main_menu(include_home: true)).to eq ''
    end

    it 'returns top level page' do
      root.children.create(slug: 'top1', published: true, title: 'Top Level 1', menutitle: 'Top')

      expect(main_menu).to eq "<ul ><li><a href=\"http://test.example.com/en/top1\">Top</a></li></ul>"
    end

    it 'returns second level page' do
      toplevel = root.children.create(slug: 'top1', published: true, title: 'Top Level 1', menutitle: 'Top')
      toplevel.children.create(slug: 'second1', published: true, title: 'Second Level 1', menutitle: 'Second')

      expect(main_menu).to eq "<ul ><li><a href=\"http://test.example.com/en/top1\">Top</a><ul ><li><a href=\"http://test.example.com/en/second1\">Second</a></li></ul></li></ul>"
    end

    it 'returns second level page with a class on submenu' do
      toplevel = root.children.create(slug: 'top1', published: true, title: 'Top Level 1', menutitle: 'Top')
      toplevel.children.create(slug: 'second1', published: true, title: 'Second Level 1', menutitle: 'Second')

      expect(main_menu(sub_menu_1: 'sub-menu')).to eq "<ul ><li><a href=\"http://test.example.com/en/top1\">Top</a><ul class=\"sub-menu\"><li><a href=\"http://test.example.com/en/second1\">Second</a></li></ul></li></ul>"
    end

    context 'bs4 menu' do
      it 'returns root page' do
        expect(main_menu(include_home: true, type: :bs4)).to eq '<ul ><li class="nav-item"><a class="nav-link" href="http://test.example.com/en/index">Home</a></li></ul>'
      end

      it 'adds class to top ul' do
        expect(main_menu(include_home: true, class: 'nav', type: :bs4)).to eq '<ul class="nav" ><li class="nav-item"><a class="nav-link" href="http://test.example.com/en/index">Home</a></li></ul>'
      end

      it 'returns two pages' do
        root.children.create(slug: 'top1', published: true, title: 'Top Level 1', menutitle: 'Top')

        expect(main_menu(include_home: true, type: :bs4)).to eq '<ul ><li class="nav-item"><a class="nav-link" href="http://test.example.com/en/index">Home</a></li><li class="nav-item"><a class="nav-link" href="http://test.example.com/en/top1">Top</a></li></ul>'
      end

      it 'returns second level page' do
        toplevel = root.children.create(slug: 'top1', published: true, title: 'Top Level 1', menutitle: 'Top')
        toplevel.children.create(slug: 'second1', published: true, title: 'Second Level 1', menutitle: 'Second')

        expect(main_menu(class: 'nav', type: :bs4)).to eq '<ul class="nav" ><li class="nav-item dropdown"><a class="nav-link dropdown-toggle" data-toggle="dropdown" href="http://test.example.com/en/top1">Top <b class="caret"></b></a><ul class="dropdown-menu"><li class="nav-item"><a class="nav-link" href="http://test.example.com/en/second1">Second</a></li></ul></li></ul>'
      end
    end
  end

  it '#page_url'
  it '#content_by_name'
  it '#content_by_name?'
  it '#snippet'
  it '#snippet?'
  it '#render_content_item'
  it '#menu_from_pages'
  it '#menu_from_pages_bs3'
  it '#allow_page_in_menu?'
  it '#main_menu_select'
  it '#page_authorized?'
  it '#current_page?'
  it '#current_page_path?'
  it '#page_in_section?'
end
