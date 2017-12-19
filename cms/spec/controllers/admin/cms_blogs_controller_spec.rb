require 'spec_helper'

describe DmCms::Admin::CmsBlogsController do

  routes { DmCms::Engine.routes }
  login_admin

  let(:blog) { create(:blog) }

  #------------------------------------------------------------------------------
  it "verify using admin role" do
    expect(@current_user.is_admin?).to eq true
  end

  describe 'GET #index' do
    #------------------------------------------------------------------------------
    it "populates an array of all documents" do
      blog2 = create(:news_blog)
      get :index, params: {locale: :en}
      expect(assigns(:blogs)).to match_array([blog, blog2])
    end

    #------------------------------------------------------------------------------
    it "renders the :index template" do
      get :index, params: {locale: :en}
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    #------------------------------------------------------------------------------
    it "assigns the requested blog to @blog" do
      get :show, params: {id: blog.id, locale: :en}
      expect(assigns(:blog)).to eq blog
    end

    #------------------------------------------------------------------------------
    it "renders the :show template" do
      get :show, params: {id: blog.id, locale: :en}
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    #------------------------------------------------------------------------------
    it "assigns a new blog to @blog" do
      get :new, params: {locale: :en}
      expect(assigns(:blog)).to be_a_new(CmsBlog)
    end
    #------------------------------------------------------------------------------
    it "renders the :new template" do
      get :new, params: {locale: :en}
      expect(response).to render_template :new
    end
  end

  describe 'GET #edit' do
    #------------------------------------------------------------------------------
    it "assigns the requested blog to @blog" do
      get :edit, params: {id: blog.id, locale: :en}
      expect(assigns(:blog)).to eq blog
    end

    #------------------------------------------------------------------------------
    it "renders the :edit template" do
      get :edit, params: {id: blog.id, locale: :en}
      expect(response).to render_template :edit
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      #------------------------------------------------------------------------------
      it "saves the new blog in the database" do
        expect {
          post :create, params: {cms_blog: attributes_for(:blog), locale: :en}
        }.to change(CmsBlog, :count).by(1)
      end

      #------------------------------------------------------------------------------
      it "redirects to cms_blog#show" do
        post :create, params: {cms_blog: attributes_for(:blog), locale: :en}
        expect(response).to redirect_to admin_cms_blog_path(assigns[:blog])
      end
    end

    context "with invalid attributes" do
      #------------------------------------------------------------------------------
      it "does not save the new document in the database" do
        expect {
          post :create, params: {cms_blog: attributes_for(:invalid_blog), locale: :en}
        }.to_not change(CmsBlog, :count)
      end

      #------------------------------------------------------------------------------
      it "re-renders the :new template" do
        post :create, params: {cms_blog: attributes_for(:invalid_blog), locale: :en}
        expect(response).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do

    context "with valid attributes" do
      #------------------------------------------------------------------------------
      it "locates the requested @blog" do
        patch :update, params: {id: blog, locale: :en, cms_blog: attributes_for(:blog)}
        expect(assigns(:blog)).to eq blog
      end

      #------------------------------------------------------------------------------
      it "updates the blog in the database" do
        patch :update, params: {id: blog, locale: :en, cms_blog: attributes_for(:blog, title: 'Updated title')}
        blog.reload
        expect(blog.title).to eq 'Updated title'
      end

      #------------------------------------------------------------------------------
      it "redirects to the updated blog" do
        patch :update, params: {id: blog, locale: :en, cms_blog: attributes_for(:blog, title: 'Updated title')}
        expect(response).to redirect_to admin_cms_blog_path(blog)
      end
    end

    context "with invalid attributes" do
      #------------------------------------------------------------------------------
      it "does not update the blog" do
        patch :update, params: {id: blog.id, locale: :en, cms_blog: attributes_for(:blog, title: nil)}
        blog.reload
        expect(blog.title).to eq(attributes_for(:blog)[:title])
      end

      #------------------------------------------------------------------------------
      it "re-renders the #edit template" do
        patch :update, params: {id: blog.id, locale: :en, cms_blog: attributes_for(:blog, title: nil)}
        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do

    #------------------------------------------------------------------------------
    it "deletes the blog from the database" do
      blog
      expect { delete :destroy, params: {id: blog.id, locale: :en} }.to change(CmsBlog, :count).by(-1)
    end

    #------------------------------------------------------------------------------
    it "redirects to cms_blog#index" do
      delete :destroy, params: {id: blog.id, locale: :en}
      expect(response).to redirect_to admin_cms_blogs_url
    end
  end

  describe 'sort' do
    it 'write test'
  end

  describe 'blog_users' do
    it 'write test'
  end

  describe 'blog_add_member' do
    it 'write test'
  end

  describe 'blog_delete_member' do
    it 'write test'
  end

end
