require 'spec_helper'

describe DmCms::PagesController do
  render_views

  routes { DmCms::Engine.routes }
  no_user

  let(:page) { create(:page) }

  describe 'GET #show' do
    #------------------------------------------------------------------------------
    it 'renders the :show template' do
      get :show, params: { slug: page.slug, locale: :en }
      expect(response).to render_template :show
    end

    #------------------------------------------------------------------------------
    it 'returns 404 is page is missing' do
      get :show, params: { slug: 'im-missing', locale: :en }
      expect(response).to have_http_status(:missing)
    end

    it 'renders the `missing` page if it exists'
    it 'raises Account::LoginRequired if page requires login and not loggged'
    it 'renders page if requires logged in and user is logged in'
    it 'sets the title, description, and og:image fields'
    it 'renders a minimal page if params[:body] is set'

    it 'renders content'

    #------------------------------------------------------------------------------
    it 'redirects to an internal slug (pagelink)' do
      target = create(:page_internal_pagelink)
      get :show, params: { slug: target.slug, locale: :en }
      # expect(response).to redirect_to showpage_url(slug: 'test-page', locale: :en)
      expect(response).to redirect_to 'http://test.example.com/en/test-page'
    end

    #------------------------------------------------------------------------------
    it 'redirects to a relative page (controller/action)' do
      target = create(:page_internal_pagelink, link: 'some/test/path')
      get :show, params: { slug: target.slug, locale: :en }
      expect(response).to redirect_to 'http://test.example.com/en/some/test/path'
    end

    #------------------------------------------------------------------------------
    it 'redirects to an external link (link)' do
      target = create(:page_external_link)
      get :show, params: { slug: target.slug, locale: :en }
      expect(response).to redirect_to 'http://another.example.com/en/test-page'
    end

    # no good way to test a new window is opened without Capybara
    #------------------------------------------------------------------------------
    it 'redirects to an external link in a new window (link-new-window)' do
      target = create(:page_external_link_new_window)
      get :show, params: { slug: target.slug, locale: :en }
      expect(response).to redirect_to 'http://another.example.com/en/test-page'
    end

    #------------------------------------------------------------------------------
    it 'renders a divider' do
      target = create(:page_divider)
      get :show, params: { slug: target.slug, locale: :en }
      expect(response.body).to have_text 'Not a real page'
    end
  end
end
