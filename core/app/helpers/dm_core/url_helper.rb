module DmCore
  module UrlHelper
    # Takes the full url path and converts to another locale
    #------------------------------------------------------------------------------
    def url_translate(locale)
      DmCore::Language.translate_url(request.url, locale)
    end

    # if a relative url path is given, then expand it by prepending the supplied
    # path.
    #------------------------------------------------------------------------------
    def expand_url(url, path)
      url.expand_url(path)
    end

    # Returns an image tag, where the src defaults to the site_assets image folder
    # Supports both relative paths and explicit url
    #------------------------------------------------------------------------------
    def site_media_image_tag(src, options = {})
      image_tag(site_asset_media_path(src), options)
    end

    # Returns an image tag, where the src defaults to the site_assets image folder
    # Supports both relative paths and explicit url
    #------------------------------------------------------------------------------
    def site_image_tag(src, options = {})
      image_tag(site_image_path(src), options)
    end

    # Returns a path to a site image, relative to the site_assets folder
    # Supports both relative paths and explicit url
    #------------------------------------------------------------------------------
    def site_image_path(src)
      rewrite_asset_path(src.expand_url("#{account_site_assets}/images/"))
    end

    # Returns a url to a site image, relative to the site_assets folder
    # Supports both relative paths and explicit url
    #------------------------------------------------------------------------------
    def site_image_url(src)
      rewrite_asset_path(src.expand_url("#{account_site_assets_url}/images/"))
    end

    # Returns a path to a site assets, relative to the site_assets folder
    # Supports both relative paths and explicit url
    #------------------------------------------------------------------------------
    def site_asset_path(src)
      rewrite_asset_path(src.expand_url("#{account_site_assets}/"))
    end

    # Returns a path to a site assets, relative to the site_assets folder
    # Supports both relative paths and explicit url
    #------------------------------------------------------------------------------
    def site_asset_url(src)
      rewrite_asset_path(src.expand_url("#{account_site_assets_url}/"))
    end

    # Returns a path to a site assets, relative to the site_assets folder
    # Supports both relative paths and explicit url
    #------------------------------------------------------------------------------
    def site_asset_media_path(src)
      rewrite_asset_path(DmCms::MediaUrlService.call(src))
    end

    # Returns a path to a site assets, relative to the site_assets folder
    # Supports both relative paths and explicit url
    #------------------------------------------------------------------------------
    def site_asset_media_url(src)
      rewrite_asset_path(DmCms::MediaUrlService.call(src))
    end

    #------------------------------------------------------------------------------
    # Following code pulled from the Rails 3.0 source.
    #    action_pack/lib/action_view/helpers/asset_tag_helper.rb
    # Generates an asset id to be used for any assets we don't want in the asset
    # pipeline.  Asset id gets appeneded as a query string to url.
    #
    # Use case: all themes are precompiled, but a single stylesheet per
    # theme lives outside the pipeline, so that it can be updated without having
    # to recompile all assets of all sites/themes.
    #
    # Simplify the task: create the asset_id and append to the url - don't currently
    # take into account asset hosts, etc.
    #------------------------------------------------------------------------------

    @@asset_timestamps_cache = {}
    @@asset_timestamps_cache_guard = Mutex.new
    @@cache_asset_timestamps = true

    # Use the RAILS_ASSET_ID environment variable or the source's
    # modification time as its cache-busting asset id.
    #------------------------------------------------------------------------------
    def rails_asset_id(source)
      asset_id = ENV["RAILS_ASSET_ID"]
      return asset_id if asset_id
      return asset_id if @@cache_asset_timestamps && (asset_id = @@asset_timestamps_cache[source])

      path      = Rails.root.join('public', source).to_s
      asset_id  = File.exist?(path) ? File.mtime(path).to_i.to_s : ''

      if @@cache_asset_timestamps
        @@asset_timestamps_cache_guard.synchronize do
          @@asset_timestamps_cache[source] = asset_id
        end
      end

      asset_id
    end

    # Break out the asset path rewrite in case plugins wish to put the asset id
    # someplace other than the query string.
    #------------------------------------------------------------------------------
    def rewrite_asset_path(source, path = nil)
      if path && path.respond_to?(:call)
        return path.call(source)
      elsif path && path.is_a?(String)
        return format(path, source)
      end

      asset_id = rails_asset_id(source)
      if asset_id.blank?
        source
      else
        source + "?#{asset_id}"
      end
    end
  end
end
