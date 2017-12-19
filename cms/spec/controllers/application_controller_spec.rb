require 'spec_helper'

describe DmCore::ApplicationController do
  no_user

  #------------------------------------------------------------------------------
  it "return the welcome page url after signin" do
    page = create(:page, slug: 'welcome', published: false)
    page.mark_as_welcome_page
    expect(controller.send(:after_sign_in_path_for, User)).to_not eq 'http://test.example.com/en/welcome'

    page.update_attribute(:published, true)
    expect(controller.send(:after_sign_in_path_for, User)).to eq 'http://test.example.com/en/welcome'
  end

end
