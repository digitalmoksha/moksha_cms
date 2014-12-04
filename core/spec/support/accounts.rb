module AccountMacros
  
  # Setup the current account.  Used for model specs.  Need to use :each, otherwise
  # the created Account does not get cleared between runs
  #------------------------------------------------------------------------------
  def setup_account
    before :each do
      Account.current = FactoryGirl.create(:account)
    end
  end

end

#------------------------------------------------------------------------------
RSpec.configure do |config|
  config.extend  AccountMacros, type: :model
end