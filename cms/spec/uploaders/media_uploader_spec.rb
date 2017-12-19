require 'carrierwave/test/matchers'

describe MediaUploader, type: :uploader do
  include CarrierWave::Test::Matchers
  setup_account

  let(:media_file) { build(:media_file) }
  let(:uploader) { MediaUploader.new(media_file, :media) }

  before do
    MediaUploader.enable_processing = true
    MediaUploader.storage = :file
    File.open("spec/support/test.png") { |f| uploader.store!(f) }
  end

  after do
    MediaUploader.enable_processing = false
    uploader.remove!
  end

  context 'different width sizes' do
    it "scales down image to the thumb size" do
      expect(uploader.thumb).to have_dimensions(200, 200)
    end

    it "scales down image to the small size" do
      expect(uploader.sm).to have_width(300)
    end

    it "scales down image to the medium size" do
      expect(uploader.md).to have_width(600)
    end

    it "scales down image to the large size" do
      expect(uploader.lg).to have_width(900)
    end
  end

  it "has the correct format" do
    expect(uploader).to be_format('png')
  end

  it 'has correct storage directory' do
    expect(uploader.store_dir).to eq('site_assets/uploads/local/media/')
  end
end