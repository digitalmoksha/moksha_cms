require 'spec_helper'

describe DmCms::MediaUrlService, type: :service do
  setup_account

  describe '#call' do
    let(:url)    { 'http://test.example.com/site_assets/uploads/test/media/2017/test.png' }
    let(:url_sm) { 'http://test.example.com/site_assets/uploads/test/media/2017/test_sm.png' }

    it 'returns missing image when nil or not found' do
      allow(MediaFile).to receive(:url_by_name).and_return(nil)
      expect(DmCms::MediaUrlService.call('test.png')).to eq(DmCms::MediaUrlService::IMAGE_MISSING)
      expect(DmCms::MediaUrlService.call(nil)).to eq(DmCms::MediaUrlService::IMAGE_MISSING)
    end

    it 'with relative path returns url to media' do
      allow(MediaFile).to receive(:url_by_name).and_return(url)
      expect(DmCms::MediaUrlService.call('test.png')).to eq(url)
    end
    
    it 'with relative path returns url to media with specific version' do
      allow(MediaFile).to receive(:url_by_name).and_return(url_sm)
      expect(DmCms::MediaUrlService.call('test.png', version: 'sm')).to include('test_sm.png')
    end
    
    it 'returns a protected asset url' do
      expect(DmCms::MediaUrlService.call('test.png', protected: true)).to eq('/protected_asset/test.png')
    end

    it 'returns the passed in absolute url' do
      expect(DmCms::MediaUrlService.call('http://test.example.com/test.png')).to eq('http://test.example.com/test.png')
    end

    it 'returns an expiring S3 link' do
      # http://docs.aws.amazon.com/sdkforruby/api/Aws/ClientStubs.html
      Aws.config.update({ 
        region: 'eu-west-1',
        s3: { stub_responses: {} }
      })
      expect(DmCms::MediaUrlService.call('s3://bucket/test.png')).to eq('https://bucket.s3-eu-west-1.amazonaws.com/test.png')
    end
  end
end
