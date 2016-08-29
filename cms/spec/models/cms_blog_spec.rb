require 'rails_helper'

describe CmsBlog do
  setup_account
  
  it 'write more tests'

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
      blog1 = create(:blog)
      blog2 = build(:blog)
      expect(blog2).not_to be_valid
      expect(blog2.errors[:slug]).to include("has already been taken")
    end

  end

end