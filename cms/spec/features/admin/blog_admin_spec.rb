require 'rails_helper'
# require 'support/devise'

# include LoginMacros

feature 'myfeature' do
  background do
    # add setup details
  end

  scenario 'my first test', :pending do
    # write the example!
    admin = create(:admin_user)
    sign_in admin
  end
end
