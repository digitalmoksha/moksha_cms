module DmCore
  module UrlHelper

    # Takes the full url path and converts to another locale
    #------------------------------------------------------------------------------
    def url_translate(locale)
      DmCore::Language.translate_url(request.url, locale)
    end
    
    # Usually don't care if a form submits a PUT or POST.  Was something submitted?
    #------------------------------------------------------------------------------
    def put_or_post?
      request.put? || request.post?
    end
  
    # Given a file name (relative or absolute), generate a full url path (usually
    # will not include the protocol)
    #------------------------------------------------------------------------------
    def file_url(file_name, options = {})
      options.reverse_merge!  default_folder: 'images', account_site_assets: account_site_assets
      if file_name.blank?
        ''
      elsif file_name.start_with?('s3://', 's3s://')
        # amazon S3 url - generate a signed expiring link
        s3_generate_expiring_link(file_name)
      elsif file_name.absolute_url?
        # it's absolute, nothing to do
        file_name
      elsif options[:protected]
        # a protected asset, append our protected asset name (which will trigger a
        # special route to handle the file)
        file_name.expand_url("/protected_asset/")
      else
        # append our site's asset folder and default folder
        folder = options[:default_folder].blank? ? '' : "#{options[:default_folder]}/"
        file_name.expand_url("#{options[:account_site_assets]}/#{folder}")
      end
    end

    # Generate an AWS S3 expiring link, using a special formatted url
    #   s3://bucket_name/object_name?expires=120    => non-SSL, expires in 120 minutes
    #   s3s://bucket_name/object_name?expires=20    => SSL, expires in 20 minutes
    #------------------------------------------------------------------------------
    def s3_generate_expiring_link(url)
      access_key  = Account.current.theme_data['AWS_ACCESS_KEY_ID']
      secret_key  = Account.current.theme_data['AWS_SECRET_ACCESS_KEY']
      uri         = URI.parse(url)
      secure      = (uri.scheme == 's3s')
      bucket      = uri.host
      object_name = uri.path.gsub(/^\//, '')
      expire_mins = (uri.query.blank? ? nil : CGI::parse(uri.query)['expires'][0]) || '10'
      
      s3 = AWS::S3.new(access_key_id: access_key, secret_access_key: secret_key)
      object = s3.buckets[bucket].objects[object_name]
      object.url_for(:get, {expires: expire_mins.to_i.minutes.from_now, secure: secure}).to_s
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
    def site_image_tag(src, options = {})
      image_tag(site_image_path(src),  options)
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
      if asset_id = ENV["RAILS_ASSET_ID"]
        asset_id
      else
        if @@cache_asset_timestamps && (asset_id = @@asset_timestamps_cache[source])
          asset_id
        else
          path = File.join(Rails.root, 'public', source)
          asset_id = File.exist?(path) ? File.mtime(path).to_i.to_s : ''

          if @@cache_asset_timestamps
            @@asset_timestamps_cache_guard.synchronize do
              @@asset_timestamps_cache[source] = asset_id
            end
          end

          asset_id
        end
      end
    end
    
    # Break out the asset path rewrite in case plugins wish to put the asset id
    # someplace other than the query string.
    #------------------------------------------------------------------------------
    def rewrite_asset_path(source, path = nil)
      if path && path.respond_to?(:call)
        return path.call(source)
      elsif path && path.is_a?(String)
        return path % [source]
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
