require 'rails_helper'

describe DmCore::ApplicationController do
  # routes { DmCms::Engine.routes }
  # login_user
  
  #------------------------------------------------------------------------------
  it "return the welcome page url after signin" do
    Account.current = FactoryGirl.create(:account)
    page = create(:page, slug: 'welcome')
    page.mark_as_welcome_page
    expect(controller.send(:after_sign_in_path_for, User)).to_not eq 'http://test.host/dm_cms/en/welcome'

    page.update_attribute(:published, true)
    expect(controller.send(:after_sign_in_path_for, User)).to eq 'http://test.host/dm_cms/en/welcome'
  end

end
