require 'rails_helper'

describe DmCms::Admin::CmsPostsController do
  routes { DmCms::Engine.routes }
  login_admin
  
  #------------------------------------------------------------------------------
  it "verify using admin role" do
    expect(@current_user.is_admin?).to eq true
  end

  describe 'GET #new' do
    let(:blog) { create(:blog) }
    
    #------------------------------------------------------------------------------
    it "assigns a new Post to @post" do
      get :new, cms_blog_id: blog
      expect(assigns(:post)).to be_a_new(CmsPost)
    end
    #------------------------------------------------------------------------------
    it "renders the :new template" do
      get :new, cms_blog_id: blog
      expect(response).to render_template :new
    end
  end

  describe 'GET #edit' do
    let(:blog) { create(:blog) }
    let(:post) { blog.posts.create(attributes_for(:post)) }
    
    #------------------------------------------------------------------------------
    it "assigns the requested post to @post" do
      get :edit, cms_blog_id: blog, id: post
      expect(assigns(:post)).to eq post
    end

    #------------------------------------------------------------------------------
    it "renders the :edit template" do
      get :edit, cms_blog_id: blog, id: post
      expect(response).to render_template :edit
    end

    #------------------------------------------------------------------------------
    it "ensure the edited post is scoped to the correct blog (same slugs, different blogs)" do
      blog2 = create(:news_blog)
      post2 = blog2.posts.create(attributes_for(:post))

      get :edit, cms_blog_id: blog, id: post
      expect(assigns(:post)).to eq post
      get :edit, cms_blog_id: blog2, id: post2
      expect(assigns(:post)).to eq post2
    end
  end

  describe "POST #create" do
    let(:blog) { create(:blog) }

    context "with valid attributes" do
      #------------------------------------------------------------------------------
      it "saves the new post in the database" do
        expect {
          post :create, cms_blog_id: blog, cms_post: attributes_for(:post)
        }.to change(blog.posts, :count).by(1)
      end

      #------------------------------------------------------------------------------
      it "redirects to blog#show" do
        post :create, cms_blog_id: blog, cms_post: attributes_for(:post)
        expect(response).to redirect_to admin_cms_blog_url(assigns[:blog])
      end
    end

    context "with invalid attributes" do
      #------------------------------------------------------------------------------
      it "does not save the new post in the database" do
        expect {
          post :create, cms_blog_id: blog, cms_post: attributes_for(:invalid_post)
        }.to_not change(blog.posts, :count)
      end

      #------------------------------------------------------------------------------
      it "re-renders the :new template" do
        post :create, cms_blog_id: blog, cms_post: attributes_for(:invalid_post)
        expect(response).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do
    let(:blog) { create(:blog) }
    let(:post) { blog.posts.create(attributes_for(:post)) }

    context "with valid attributes" do
      #------------------------------------------------------------------------------
      it "locates the requested @post" do
        blog2 = create(:news_blog)
        post2 = blog2.posts.create(attributes_for(:post))

        patch :update, cms_blog_id: blog, id: post, cms_post: attributes_for(:post)
        expect(assigns(:post)).to eq post
        patch :update, cms_blog_id: blog2, id: post2, cms_post: attributes_for(:post)
        expect(assigns(:post)).to eq post2
      end

      #------------------------------------------------------------------------------
      it "updates the post in the database" do
        patch :update, cms_blog_id: blog, id: post, cms_post: attributes_for(:post, title: 'Updated title', content: 'Updated content')
        post.reload
        expect(post.title).to eq('Updated title')
        expect(post.content).to eq('Updated content')
      end

      #------------------------------------------------------------------------------
      it "redirects to the blog" do
        patch :update, cms_blog_id: blog, id: post, cms_post: attributes_for(:post)
        expect(response).to redirect_to admin_cms_blog_url(blog)
      end
    end

    context "with invalid attributes" do
      #------------------------------------------------------------------------------
      it "does not update the post" do
        patch :update, cms_blog_id: blog, id: post, cms_post: attributes_for(:post, title: 'Updated title', content: nil)
        post.reload
        expect(post.title).to eq(attributes_for(:post)[:title])
        expect(post.content).to eq(attributes_for(:post)[:content])
      end

      #------------------------------------------------------------------------------
      it "re-renders the #edit template" do
        patch :update, cms_blog_id: blog, id: post, cms_post: attributes_for(:post, title: 'Updated title', content: nil)
        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:blog) { create(:blog) }
    let(:post) { blog.posts.create(attributes_for(:post)) }

    #------------------------------------------------------------------------------
    it "deletes the post from the blog" do
      post # make sure post is created before the expect
      expect { delete :destroy, cms_blog_id: blog, id: post }.to change(blog.posts, :count).by(-1)
    end

    #------------------------------------------------------------------------------
    it "redirects to cms_blogs#index" do
      delete :destroy, cms_blog_id: blog, id: post
      expect(response).to redirect_to admin_cms_blog_url(blog)
    end
  end

  describe 'PATCH #send_notifications_emails' do
    it "write test"
  #   #------------------------------------------------------------------------------
  #   it "replaces the tags on a srcid with the given tag list" do
  #     document = create(:document)
  #     document.set_tag_list_on(DmKnowledge::Document.tagcontext_from_srcid('1.12'), "tag1,tag2")
  #     document.save
  #     patch :add_tags, id: document.id, document: {srcid: '1.12', tag_list: 'tag3, tag4'}
  #     document.reload
  #     expect(DmKnowledge::Document.all_tags_list).to eq ['tag3', 'tag4']
  #   end
  end
end
