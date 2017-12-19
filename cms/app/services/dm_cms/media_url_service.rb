# Given a partial url, return a full url to the appropriate media file.
# If it's an absolute or S3 url, handle it.
#------------------------------------------------------------------------------
module DmCms
  class MediaUrlService
    include DmCore::ServiceSupport
    include DmCore::AccountHelper

    IMAGE_MISSING = '/image_missing.png'

    #------------------------------------------------------------------------------
    def initialize(src, options = {})
      options.symbolize_keys!
      @src     = src
      @version = options.delete(:version) || :original
      @protect = options.delete(:protected).as_boolean
    end

    #------------------------------------------------------------------------------
    def call
      return IMAGE_MISSING if @src.blank?
      if @src.absolute_url?
        if @src.start_with?('s3://', 's3s://')
          DmCore::S3SignedUrlService.new.generate(@src)  # amazon S3 url - generate a signed expiring link
        else
          @src
        end
      else
        if @protect
          @src.expand_url("#{account_protected_assets_base}/")
        else
          MediaFile.url_by_name(@src, version: @version) || IMAGE_MISSING
        end
      end

    end
  end
end