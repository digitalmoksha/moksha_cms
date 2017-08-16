require 'spec_helper'

describe DmCore::S3SignedUrlService, type: :service do
  setup_account
  
  describe '#generate' do

    before do
      # http://docs.aws.amazon.com/sdkforruby/api/Aws/ClientStubs.html
      Aws.config[:s3] = { stub_responses: {} }
    end

    it 'an unsigned, non-expiring public url' do
      url = DmCore::S3SignedUrlService.new(region: 'eu-west-1').generate('s3://bucket/test.png')
      expect(url).to eq 'https://bucket.s3-eu-west-1.amazonaws.com/test.png'
    end
    
    it 'an unsigned, non-expiring public url (using s3s://)' do
      url = DmCore::S3SignedUrlService.new(region: 'eu-west-1').generate('s3s://bucket/test.png')
      expect(url).to eq 'https://bucket.s3-eu-west-1.amazonaws.com/test.png'
    end
    
    it 'a signed, expiring public url' do
      url = DmCore::S3SignedUrlService.new(region: 'eu-west-1').generate('s3://bucket/test.png?expires=120')
      expect(url).to include('https://bucket.s3-eu-west-1.amazonaws.com/test.png')
      expect(url).to include('SignedHeaders=')
      expect(url).to include('Expires=7200')
    end

  end
end
