require 'spec_helper'
require_relative Rails.root.join '../../../core/spec/concerns/public_private_shared'

describe CmsBlog do
  setup_account

  it { is_expected.to validate_length_of(:slug).is_at_most(255) }
  it { is_expected.to validate_length_of(:header_image).is_at_most(255) }
  it { is_expected.to validate_length_of(:image_email_header).is_at_most(255) }
  it { is_expected.to validate_length_of(:title_en).is_at_most(255) }
  it_behaves_like :public_private_protected, :blog

  describe 'slug handling' do
    #------------------------------------------------------------------------------
    it 'allows the same blog slug per account (scoped to account)' do
      blog1 = create(:blog)
      Account.current = create(:second_account)
      blog2 = create(:blog)

      expect(blog1.account_id).not_to eq blog2.account_id
      expect(blog1.slug).to eq blog2.slug
    end

    #------------------------------------------------------------------------------
    it 'creates a unique auto-generated slug for blogs in the same account' do
      blog1 = create(:blog)
      blog2 = create(:blog, slug: nil)

      expect(blog1.account_id).to eq blog2.account_id
      expect(blog1.slug).not_to eq blog2.slug
    end

    #------------------------------------------------------------------------------
    it 'raises an error when same slug is specified for blogs in the same account' do
      create(:blog, slug: 'test')
      blog2 = build(:blog, slug: 'test')

      expect(blog2).not_to be_valid
      expect(blog2.errors[:slug]).to include("has already been taken")
    end

    #------------------------------------------------------------------------------
    it 'creates an auto-generated slug based on the title' do
      blog = create(:blog, slug: nil)

      expect(blog.slug).to eq 'test-blog'
    end
  end

  describe 'tag handling' do
    let(:blog1) { create(:blog) }

    #------------------------------------------------------------------------------
    it 'creates a tag' do
      expect(blog1.tag_list).to eq []

      blog1.update_attribute(:tag_list, 'one, two')

      expect(blog1.tag_list).to eq ['one', 'two']
    end

    #------------------------------------------------------------------------------
    it 'all tags across blogs' do
      blog1.update_attribute(:tag_list, 'one, two')
      blog2 = create(:blog, slug: nil)
      blog2.update_attribute(:tag_list, 'one, three')

      expect(described_class.tag_list_all).to eq ['one', 'three', 'two']
    end
  end
end
