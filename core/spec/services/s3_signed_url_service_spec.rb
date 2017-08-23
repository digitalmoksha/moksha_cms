require 'spec_helper'

describe DmCore::S3SignedUrlService, type: :service do
  setup_account
  
  describe '#generate' do

    before do
      # http://docs.aws.amazon.com/sdkforruby/api/Aws/ClientStubs.html
      Aws.config.update({ 
        region: 'eu-west-1',
        s3: { stub_responses: {} }
      })
    end

    it 'an unsigned, non-expiring public url' do
      url = DmCore::S3SignedUrlService.new.generate('s3://bucket/test.png?expires=0')
      expect(url).to eq 'https://bucket.s3-eu-west-1.amazonaws.com/test.png'

      url = DmCore::S3SignedUrlService.new.generate('s33://bucket/test.png?expires=public')
      expect(url).to eq 'https://bucket.s3-eu-west-1.amazonaws.com/test.png'
    end
    
    it 'defaults to 10 minute expiration' do
      url = DmCore::S3SignedUrlService.new.generate('s3s://bucket/test.png')
      expect(url).to include('https://bucket.s3-eu-west-1.amazonaws.com/test.png')
      expect(url).to include('SignedHeaders=')
      expect(url).to include('Expires=600')
    end
    
    it 'a signed, expiring public url' do
      url = DmCore::S3SignedUrlService.new.generate('s3://bucket/test.png?expires=120')
      expect(url).to include('https://bucket.s3-eu-west-1.amazonaws.com/test.png')
      expect(url).to include('SignedHeaders=')
      expect(url).to include('Expires=7200')
    end

  end
end
