module DmCore
  module AccountHelper

    #------------------------------------------------------------------------------
    def current_account
      Account.current
    end

  private
  
    # setup the account scope, used for scoping models to an Account
    #------------------------------------------------------------------------------
    def scope_current_account
      Account.current = Account.find_account(request.host)
      yield
    ensure
      Account.current = nil
    end

  end
end
