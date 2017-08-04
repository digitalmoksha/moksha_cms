module DmCore
  module AccountHelper

    PROTECTED_ASSETS_FOLDER = 'protected_assets'
    PROTECTED_ASSET_TRIGGER = 'protected_asset'  # name used to trigger the special route
    SITE_ASSETS_FOLDER      = 'site_assets'

    #------------------------------------------------------------------------------
    def current_account
      Account.current
    end

    # Get the account prefix that is used for locating items on the filesystem.
    #------------------------------------------------------------------------------
    def account_prefix
      current_account.account_prefix
    end

    # Returns the path (from the root of the site) to the base site specific directory
    #   Pass in false not to include leading slash
    #------------------------------------------------------------------------------
    def account_site_assets_base(leading_slash = true)
      leading_slash ? "/#{SITE_ASSETS_FOLDER}" : SITE_ASSETS_FOLDER
    end

    #------------------------------------------------------------------------------
    def account_protected_assets_base(leading_slash = true)
      leading_slash ? "/#{PROTECTED_ASSET_TRIGGER}" : PROTECTED_ASSET_TRIGGER
    end

    #------------------------------------------------------------------------------
    def account_protected_assets_folder
      "#{Rails.root}/#{PROTECTED_ASSETS_FOLDER}"
    end

    # Returns the path (from the root of the site) to the site general asset files
    #   Pass in false not to include leading slash
    #------------------------------------------------------------------------------
    def account_site_assets(leading_slash = true)
      "#{account_site_assets_base(leading_slash)}/content/#{account_prefix}"
    end

    # Returns the path (from the root of the site) to the protected asset files
    #------------------------------------------------------------------------------
    def account_protected_assets_media_folder
      "#{account_protected_assets_folder}/uploads/#{account_prefix}"
    end

    # Returns the path (from the root of the site) to the site's uploadable asset
    # folder, which is 'media'
    #   Pass in false not to include leading slash
    #------------------------------------------------------------------------------
    def account_site_assets_media(leading_slash = true)
      "#{account_site_assets_base(leading_slash)}/uploads/#{account_prefix}"
    end

    # Returns the url of the site's base site specific directory
    #   Pass in false not to include leading slash
    #------------------------------------------------------------------------------
    def account_site_assets_base_url
      Account.current.url_base + account_site_assets_base(true)
    end

    # Returns the url of the site's general asset files
    #   Pass in false not to include leading slash
    #------------------------------------------------------------------------------
    def account_site_assets_url
      Account.current.url_base + account_site_assets(true)
    end

    # Returns the url of the site's media asset files
    #   Pass in false not to include leading slash
    #------------------------------------------------------------------------------
    def account_site_assets_media_url
      Account.current.url_base + account_site_assets_media(true)
    end

  private
  
    # setup the account scope, used for scoping models to an Account
    #------------------------------------------------------------------------------
    def scope_current_account
      Account.current           = Account.find_account(request.host)
      #--- set the current request site url for use where request object is not avail,
      #    like in ActionMailer
      Account.current.set_url_parts(request.protocol, request.host_with_port)
      yield
    ensure
      # Ensure that once this request is done, the Account.current (which 
      # is stored in thread storage) is cleared.
      # When testing, it's better *not* to clear it, since expectations
      # after the controller call may need the current account
      Account.current = nil unless Rails.env.test?
    end

  end
end
