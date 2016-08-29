require 'rails_helper'

describe CmsPost do
  setup_account

  it 'write more tests'
  
  describe 'slug handling' do

    let(:blog1) { create(:blog) }
    let(:blog2) { create(:news_blog)}
    
    #------------------------------------------------------------------------------
    it 'allows the same specified slug between two blogs (scoped to blog)' do
      post1 = blog1.posts.create(attributes_for(:post, slug: 'test-slug'))
      post2 = blog2.posts.create(attributes_for(:post, slug: 'test-slug'))
      expect(post1.slug).to eq post2.slug
    end

    #------------------------------------------------------------------------------
    it 'allows the same auto-generated slug between two blogs (scoped to blog)' do
      post1 = blog1.posts.create(attributes_for(:post, slug: nil))
      post2 = blog2.posts.create(attributes_for(:post, slug: nil))
      expect(post1.slug).to eq post2.slug
    end

    #------------------------------------------------------------------------------
    it 'raises an error when same slug is specified for posts in the same blog' do
      post1 = blog1.posts.create(attributes_for(:post, slug: 'test-slug'))
      post2 = blog1.posts.create(attributes_for(:post, slug: 'test-slug'))
      expect(post2).not_to be_valid
      expect(post2.errors[:slug]).to include("has already been taken")
    end

    #------------------------------------------------------------------------------
    it 'creates a unique auto-generated slug for posts in the same blog' do
      post1 = blog1.posts.create(attributes_for(:post, slug: nil))
      post2 = blog1.posts.create(attributes_for(:post, slug: nil))
      expect(post1.slug).not_to eq post2.slug
    end

  end

end