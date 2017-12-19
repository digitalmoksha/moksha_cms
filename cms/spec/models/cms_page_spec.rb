require 'spec_helper'

describe CmsPage do
  setup_account

  it { is_expected.to validate_length_of(:slug).is_at_most(255) }
  it { is_expected.to validate_length_of(:template).is_at_most(50) }
  it { is_expected.to validate_length_of(:link).is_at_most(255) }
  it { is_expected.to validate_length_of(:menuimage).is_at_most(255) }
  it { is_expected.to validate_length_of(:featured_image).is_at_most(255) }
  it { is_expected.to validate_length_of(:header_image).is_at_most(255) }
  it { is_expected.to validate_length_of(:title_en).is_at_most(255) }
  it { is_expected.to validate_length_of(:menutitle_en).is_at_most(255) }

  #------------------------------------------------------------------------------
  it 'finds single welcome page' do
    page = create(:page)
    expect(CmsPage.welcome_page).to eq nil
    page.mark_as_welcome_page
    expect(CmsPage.welcome_page).to eq page

    page2 = create(:page, slug: 'welcome')
    page2.mark_as_welcome_page
    expect(CmsPage.welcome_page).to eq page2
  end

  describe 'tag handling' do

    let(:page) { create(:page) }

    #------------------------------------------------------------------------------
    it 'creates a tag' do
      expect(page.tag_list).to eq []
      page.update_attribute(:tag_list, 'one, two')
      expect(page.tag_list).to eq ['one', 'two']
    end

    #------------------------------------------------------------------------------
    it 'all tags across pages' do
      page.update_attribute(:tag_list, 'one, two')
      page2 = create(:page, slug: nil)
      page2.update_attribute(:tag_list, 'one, three')
      expect(CmsPage.tag_list_all).to eq ['one', 'three', 'two']
    end

  end
end