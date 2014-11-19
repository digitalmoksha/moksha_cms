require 'devise'

# from https://github.com/plataformatec/devise/wiki/How-To:-Test-controllers-with-Rails-3-and-4-(and-RSpec)
#------------------------------------------------------------------------------
module LoginMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @current_user = FactoryGirl.create(:user_admin)
      sign_in @current_user
    end
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @current_user = FactoryGirl.create(:user)
      # user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
      sign_in @current_user
    end
  end
end

#------------------------------------------------------------------------------
RSpec.configure do |config|
  config.include  Devise::TestHelpers,  type: :controller
  config.extend   LoginMacros,          type: :controller
end