require 'devise'

# from https://github.com/plataformatec/devise/wiki/How-To:-Test-controllers-with-Rails-3-and-4-(and-RSpec)
#------------------------------------------------------------------------------
module LoginMacros
  
  #------------------------------------------------------------------------------
  def login_admin
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @request.host   = "test.example.com"   # domain must match the account being used
      Account.current = FactoryGirl.create(:account)
      @current_user   = FactoryGirl.create(:admin_user)
      sign_in @current_user
    end
  end

  #------------------------------------------------------------------------------
  def login_user
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @request.host   = "test.example.com"   # domain must match the account being used
      Account.current = FactoryGirl.create(:account)
      @current_user   = FactoryGirl.create(:user)
      sign_in @current_user
    end
  end
  
  #------------------------------------------------------------------------------
  def sign_in(user)
    visit main_app.new_user_session_path
    # click_link 'Log In'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign in'
  end
end

#------------------------------------------------------------------------------
RSpec.configure do |config|
  config.include  Devise::TestHelpers,  type: :controller
  config.extend   LoginMacros,          type: :controller
  config.include  LoginMacros,          type: :feature
end