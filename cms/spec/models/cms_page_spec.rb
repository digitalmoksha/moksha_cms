require 'rails_helper'

describe CmsPage do
  setup_account

  #------------------------------------------------------------------------------
  it 'write tests'

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
end