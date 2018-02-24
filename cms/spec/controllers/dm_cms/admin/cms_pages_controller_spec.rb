require 'spec_helper'

describe DmCms::Admin::CmsPagesController do
  routes { DmCms::Engine.routes }
  login_admin

  #------------------------------------------------------------------------------
  it "verify using admin role" do
    expect(@current_user.is_admin?).to eq true
  end

  it "write tests"

  # describe 'GET #index' do
  #   #------------------------------------------------------------------------------
  #   it "populates an array of all documents" do
  #     document1 = create(:document)
  #     document2 = create(:document, title: 'Another document')
  #     get :index, locale: :en
  #     expect(assigns(:documents)).to match_array([document1, document2])
  #   end
  #
  #   #------------------------------------------------------------------------------
  #   it "renders the :index template" do
  #     blog = create(:blog)
  #
  #     get :index, cms_blog_id: blog.id
  #     expect(response).to render_template :index
  #   end
  # end

  # describe 'GET #show' do
  #   #------------------------------------------------------------------------------
  #   it "assigns the requested contact to @document" do
  #     document = create(:document)
  #     get :show, id: document.id
  #     expect(assigns(:document)).to eq document
  #   end
  #
  #   #------------------------------------------------------------------------------
  #   it "renders the :show template" do
  #     document = create(:document)
  #     get :show, id: document.id
  #     expect(response).to render_template :show
  #   end
  # end
  #
  # describe 'GET #new' do
  #   #------------------------------------------------------------------------------
  #   it "assigns a new Document to @document" do
  #     get :new
  #     expect(assigns(:document)).to be_a_new(DmKnowledge::Document)
  #   end
  #   #------------------------------------------------------------------------------
  #   it "renders the :new template" do
  #     get :new
  #     expect(response).to render_template :new
  #   end
  # end
  #
  # describe 'GET #edit' do
  #   #------------------------------------------------------------------------------
  #   it "assigns the requested document to @document" do
  #     document = create(:document)
  #     get :edit, id: document.id
  #     expect(assigns(:document)).to eq document
  #   end
  #
  #   #------------------------------------------------------------------------------
  #   it "renders the :edit template" do
  #     document = create(:document)
  #     get :edit, id: document.id
  #     expect(response).to render_template :edit
  #   end
  # end
  #
  # describe "POST #create" do
  #   context "with valid attributes" do
  #     #------------------------------------------------------------------------------
  #     it "saves the new document in the database" do
  #       expect {
  #         post :create, document: attributes_for(:document)
  #       }.to change(DmKnowledge::Document, :count).by(1)
  #     end
  #
  #     #------------------------------------------------------------------------------
  #     it "redirects to documents#show" do
  #       post :create, document: attributes_for(:document)
  #       expect(response).to redirect_to admin_document_path(assigns[:document].id)
  #     end
  #   end
  #
  #   context "with invalid attributes" do
  #     #------------------------------------------------------------------------------
  #     it "does not save the new document in the database" do
  #       expect {
  #         post :create, document: attributes_for(:invalid_document)
  #       }.to_not change(DmKnowledge::Document, :count)
  #     end
  #
  #     #------------------------------------------------------------------------------
  #     it "re-renders the :new template" do
  #       post :create, document: attributes_for(:invalid_document)
  #       expect(response).to render_template :new
  #     end
  #   end
  # end
  #
  # describe 'PATCH #update' do
  #   before do
  #     @document = create(:document)
  #   end
  #
  #   context "with valid attributes" do
  #     #------------------------------------------------------------------------------
  #     it "locates the requested @document" do
  #       patch :update, id: @document.id, document: attributes_for(:document)
  #       expect(assigns(:document)).to eq(@document)
  #     end
  #
  #     #------------------------------------------------------------------------------
  #     it "updates the document in the database" do
  #       date = Time.now
  #       patch :update, id: @document.id, document: attributes_for(:document, title: 'Update title', original_date: date)
  #       @document.reload
  #       expect(@document.title).to eq('Update title')
  #       expect(@document.original_date).to eq(date.to_s)
  #     end
  #
  #     #------------------------------------------------------------------------------
  #     it "redirects to the updated document" do
  #       patch :update, id: @document.id, document: attributes_for(:document)
  #       expect(response).to redirect_to admin_document_path(@document.id)
  #     end
  #   end
  #
  #   context "with invalid attributes" do
  #     #------------------------------------------------------------------------------
  #     it "does not update the document" do
  #       patch :update, id: @document.id, document: attributes_for(:document, title: 'Update title', original_date: nil)
  #       @document.reload
  #       expect(@document.title).to eq(attributes_for(:document)[:title])
  #       expect(@document.original_date).to eq(attributes_for(:document)[:original_date])
  #     end
  #
  #     #------------------------------------------------------------------------------
  #     it "re-renders the #edit template" do
  #       patch :update, id: @document.id, document: attributes_for(:invalid_document)
  #       expect(response).to render_template :edit
  #     end
  #   end
  # end
  #
  # describe 'DELETE #destroy' do
  #   before do
  #     @document = create(:document)
  #   end
  #
  #   #------------------------------------------------------------------------------
  #   it "deletes the document from the database" do
  #     expect { delete :destroy, id: @document.id }.to change(DmKnowledge::Document, :count).by(-1)
  #   end
  #
  #   #------------------------------------------------------------------------------
  #   it "redirects to documents#index" do
  #     delete :destroy, id: @document.id
  #     expect(response).to redirect_to admin_documents_url
  #   end
  # end
  #
  # describe 'PATCH #add_tags' do
  #   #------------------------------------------------------------------------------
  #   it "replaces the tags on a srcid with the given tag list" do
  #     document = create(:document)
  #     document.set_tag_list_on(DmKnowledge::Document.tagcontext_from_srcid('1.12'), "tag1,tag2")
  #     document.save
  #     patch :add_tags, id: document.id, document: {srcid: '1.12', tag_list: 'tag3, tag4'}
  #     document.reload
  #     expect(DmKnowledge::Document.all_tags_list).to eq ['tag3', 'tag4']
  #   end
  # end
end
