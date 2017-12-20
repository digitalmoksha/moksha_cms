require 'devise'

# from https://github.com/plataformatec/devise/wiki/How-To:-Test-controllers-with-Rails-3-and-4-(and-RSpec)
#------------------------------------------------------------------------------
module LoginMacros

  TEST_DOMAIN = 'test.example.com'

  #------------------------------------------------------------------------------
  def login_admin
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @request.host   = TEST_DOMAIN   # domain must match the account being used
      Account.current = FactoryBot.create(:account)
      @current_user   = FactoryBot.create(:admin_user)
      sign_in @current_user
    end
  end

  #------------------------------------------------------------------------------
  def login_user
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @request.host   = TEST_DOMAIN   # domain must match the account being used
      Account.current = FactoryBot.create(:account)
      @current_user   = FactoryBot.create(:user)
      sign_in @current_user
    end
  end

  #------------------------------------------------------------------------------
  def no_user
    before :each do
      @request.host   = TEST_DOMAIN   # domain must match the account being used
      Account.current = FactoryBot.create(:account)
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
  config.include  Devise::Test::ControllerHelpers,  type: :controller
  config.include  Devise::Test::ControllerHelpers,  type: :helper
  config.include  Devise::Test::ControllerHelpers,  type: :view
  config.include  Devise::Test::IntegrationHelpers, type: :feature
  config.include  Warden::Test::Helpers,            type: :request
  config.extend   LoginMacros,                      type: :controller
  config.include  LoginMacros,                      type: :feature
end