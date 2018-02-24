require 'spec_helper'
require_relative Rails.root.join '../../../core/spec/concerns/public_private_shared'

describe Course do
  setup_account

  it { is_expected.to validate_length_of(:slug).is_at_most(255) }
  it { is_expected.to validate_length_of(:title_en).is_at_most(255) }
  it { is_expected.to validate_length_of(:menutitle_en).is_at_most(255) }
  it_behaves_like :public_private_protected, :course

  describe 'slug handling' do
    #------------------------------------------------------------------------------
    it 'allows the same course slug per account (scoped to account)' do
      course1 = create(:course)
      Account.current = create(:second_account)
      course2 = create(:course)

      expect(course1.account_id).not_to eq course2.account_id
      expect(course1.slug).to eq course2.slug
    end

    #------------------------------------------------------------------------------
    it 'creates a unique auto-generated slug for courses in the same account' do
      course1 = create(:course)
      course2 = create(:course, slug: nil)

      expect(course1.account_id).to eq course2.account_id
      expect(course1.slug).not_to eq course2.slug
    end

    #------------------------------------------------------------------------------
    it 'raises an error when same slug is specified for courses in the same account' do
      create(:course, slug: 'test')
      course2 = build(:course, slug: 'test')

      expect(course2).not_to be_valid
      expect(course2.errors[:slug]).to include("has already been taken")
    end

    #------------------------------------------------------------------------------
    it 'creates an auto-generated slug based on the title' do
      course = create(:course, slug: nil)

      expect(course.slug).to eq 'test-course'
    end
  end
end
