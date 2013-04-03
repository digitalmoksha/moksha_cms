module DmCore
  module AccountHelper

    #------------------------------------------------------------------------------
    def current_account
      Account.current
    end

    # Get the account prefix that is used for locating items on the filesystem.
    #------------------------------------------------------------------------------
    def account_prefix
      current_account.account_prefix
    end

    # Returns the path (from the root of the site) to the site general asset files
    #   Pass in false not to include leading slash
    #------------------------------------------------------------------------------
    def account_site_assets(leading_slash = true)
      leading_slash ? "/site_assets/#{account_prefix}/site" : "site_assets/#{account_prefix}/site"
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
