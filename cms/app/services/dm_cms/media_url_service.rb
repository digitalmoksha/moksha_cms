# Given a partial url, return a full url to the appropriate media file.
# If it's an absolute or S3 url, handle it.
#------------------------------------------------------------------------------
module DmCms
  class MediaUrlService
    include DmCore::ServiceSupport
    include DmCore::AccountHelper

    #------------------------------------------------------------------------------
    def initialize(src, options = {})
      options.symbolize_keys!
      @src     = src
      @version = options.delete(:version) || :original
      @protect = options.delete(:protected).as_boolean
    end

    #------------------------------------------------------------------------------
    def call
      return '' if @src.blank?
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
          MediaFile.url_by_name(@src, version: @version)
        end
      end
     
    end

    # # Given a file name (relative or absolute), generate a full url path (usually
    # # will not include the protocol)
    # #------------------------------------------------------------------------------
    # def file_url(file_name, options = {})
    #   options.reverse_merge!  base: account_site_assets_media
    #   if file_name.blank?
    #     ''
    #   elsif file_name.start_with?('s3://', 's3s://')
    #     # amazon S3 url - generate a signed expiring link
    #     s3_generate_expiring_link(file_name)
    #   elsif file_name.absolute_url?
    #     # it's absolute, nothing to do
    #     file_name
    #   elsif options[:protected]
    #     # a protected asset, append our protected asset name (which will trigger a
    #     # special route to handle the file)
    #     file_name.expand_url("#{account_protected_assets_base}/")
    #   else
    #     # append our site's asset folder and default folder
    #     file_name.expand_url("#{options[:base]}/")
    #   end
    # end
  end
  
  
  
  
  # format_list = []
  # format_list << ['mp3', file_url(@attributes["mp3"], base: context_account_site_assets_media(context), protected: @attributes['protected'].as_boolean)] if @attributes['mp3']
  # format_list << ['m4a', file_url(@attributes["m4a"], base: context_account_site_assets_media(context), protected: @attributes['protected'].as_boolean)] if @attributes['m4a']
  # format_list << ['ogg', file_url(@attributes["ogg"], base: context_account_site_assets_media(context), protected: @attributes['protected'].as_boolean)] if @attributes['ogg']
  # format_list << ['oga', file_url(@attributes["oga"], base: context_account_site_assets_media(context), protected: @attributes['protected'].as_boolean)] if @attributes['oga']
  # supplied_formats = format_list.collect {|z| z[0] }.join(', ')
  # context.registers[:view].render(partial: 'liquid_tags/audio',
  #                   locals: {player_id:         player_id,
  #                            audio_title:       @attributes['title'],
  #                            format_list:       format_list,
  #                            supplied_formats:  supplied_formats
  #                          })
  

end