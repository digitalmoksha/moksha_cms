module DmCore
  module AccountHelper

    PROTECTED_ASSETS_FOLDER = 'protected_assets'.freeze
    PROTECTED_ASSET_TRIGGER = 'protected_asset'.freeze  # name used to trigger the special route
    SITE_ASSETS_FOLDER      = 'site_assets'.freeze

    #------------------------------------------------------------------------------
    def current_account
      Account.current
    end

    # Get the account prefix that is used for locating items on the filesystem.
    #------------------------------------------------------------------------------
    def account_prefix
      current_account.account_prefix
    end

    # Site specific assets (such as static content in the repository, and user uploaded files)
    # are stored in the `/site_assets` directory:
    #  /site_assets
    #      content
    #         [account_prefix]
    #            images, stylesheets, etc (these items are typically checked into the repo)
    #      uploads
    #         [account_prefix]
    #            media (files uploaded by the content management system for blogs, pages, etc)
    #            directories for other uploaders, maybe for online courses, etc.
    #  /protected_asset
    #      uploads
    #         [account_prefix]
    #            media (files uploaded by the content management system that are to be access protected)
    #
    # The following methods provide the various paths to the directories

    # Returns the path (from the root of the site) to the base site specific directory
    # eg: /site_assets
    #------------------------------------------------------------------------------
    def account_site_assets_base(leading_slash = true)
      leading_slash ? "/#{SITE_ASSETS_FOLDER}" : SITE_ASSETS_FOLDER
    end

    # Returns the path (from the root of the site) to the content asset files
    # eg: /site_assets/content/[account_prefix]
    #------------------------------------------------------------------------------
    def account_site_assets(leading_slash = true)
      "#{account_site_assets_base(leading_slash)}/content/#{account_prefix}"
    end

    # Returns the path (from the root of the site) to the uploads directory
    # eg: /site_assets/uploads/[account_prefix]
    #------------------------------------------------------------------------------
    def account_site_assets_uploads(leading_slash = true)
      "#{account_site_assets_base(leading_slash)}/uploads/#{account_prefix}"
    end

    # Returns the path (from the root of the site) to the site's uploadable asset
    # folder for the CMS, which is 'media'
    # eg: /site_assets/uploads/[account_prefix]/media
    #------------------------------------------------------------------------------
    def account_site_assets_media(leading_slash = true)
      "#{account_site_assets_uploads(leading_slash)}/media"
    end

    # Returns the url to the base site specific directory
    # eg: http://mysite.com/site_assets
    #------------------------------------------------------------------------------
    def account_site_assets_base_url
      Account.current.url_base + account_site_assets_base(true)
    end

    # Returns the url of the site's general asset files
    # eg: http://mysite.com/site_assets/content/[account_prefix]
    #------------------------------------------------------------------------------
    def account_site_assets_url
      Account.current.url_base + account_site_assets(true)
    end

    # Returns the url of the site's media asset files
    # eg: http://mysite.com/site_assets/uploads/[account_prefix]/media
    #------------------------------------------------------------------------------
    def account_site_assets_media_url
      Account.current.url_base + account_site_assets_media(true)
    end



    # Returns the path (from the root of the site) to the protected asset directory
    # It is built with the trigger word, `protected_asset`, which will trigger the
    # special route that adds the protection
    # eg: /protected_asset
    #------------------------------------------------------------------------------
    def account_protected_assets_base(leading_slash = true)
      leading_slash ? "/#{PROTECTED_ASSET_TRIGGER}" : PROTECTED_ASSET_TRIGGER
    end

    # the actual folder on the webserver where the protected files are stored
    # eg: [Rails.root]/protected_assets
    #------------------------------------------------------------------------------
    def account_protected_assets_folder
      "#{Rails.root}/#{PROTECTED_ASSETS_FOLDER}"
    end

    # the actual folder on the webserver where the protected media files are stored
    # eg: [Rails.root]/protected_assets/uploads/[account_prefix]/media
    #------------------------------------------------------------------------------
    def account_protected_assets_media_folder
      "#{account_protected_assets_folder}/uploads/#{account_prefix}/media"
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
