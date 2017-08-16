module AccountMacros
  
  # Setup the current account.  Used for model specs.  Need to use :each, otherwise
  # the created Account does not get cleared between runs
  #------------------------------------------------------------------------------
  def setup_account
    before :each do
      @request.host = 'test.example.com' if @request   # domain must match the account being used
      account = FactoryGirl.create(:account)
      Account.current_by_prefix(account.account_prefix)
    end
  end

end

#------------------------------------------------------------------------------
RSpec.configure do |config|
  config.extend  AccountMacros, type: :model
  config.extend  AccountMacros, type: :helper
  config.extend  AccountMacros, type: :service
  config.extend  AccountMacros, type: :uploader
end