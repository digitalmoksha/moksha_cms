# Generate an AWS S3 expiring link, using a special formatted url
#   s3://bucket_name/object_name?expires=120     => SSL, expires in 120 minutes
#   s3s://bucket_name/object_name?expires=20     => SSL, expires in 20 minutes
#   s3s://bucket_name/object_name?expires=public => links directly to file (it must
#      be a World readable file, and the link will never expire)
# All urls are SSL
#------------------------------------------------------------------------------
module DmCore
  class S3SignedUrlService

    #------------------------------------------------------------------------------
    def initialize(options = {})
      @access_key  = options[:access_key] || Account.current.theme_data['AWS_ACCESS_KEY_ID']
      @secret_key  = options[:secret_key] || Account.current.theme_data['AWS_SECRET_ACCESS_KEY']
      @region      = options[:region] || Account.current.theme_data['AWS_REGION']
    end

    #------------------------------------------------------------------------------
    def generate(url)
      uri         = URI.parse(url)
      bucket      = uri.host
      object_name = uri.path.gsub(/^\//, '')
      expire_mins = (uri.query.blank? ? nil : CGI::parse(uri.query)['expires'][0]) || 'public'
      expire_secs = expire_mins.to_i.minutes.to_i  # will be 0 if 'public' or some other non-integer string
      client      = Aws::S3::Client.new(access_key_id: @access_key, secret_access_key: @secret_key, region: @region)
      s3          = Aws::S3::Resource.new(client: client)
      object      = s3.bucket(bucket).object(object_name)
      expire_secs == 0 ? object.public_url : object.presigned_url(:get, expires_in: expire_secs)
    end
  end
end