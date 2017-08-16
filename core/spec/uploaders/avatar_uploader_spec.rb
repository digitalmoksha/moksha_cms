require 'carrierwave/test/matchers'

describe AvatarUploader do
  include CarrierWave::Test::Matchers

  let(:user) { double('user') }
  let(:uploader) { AvatarUploader.new(user, :avatar) }

  before do
    AvatarUploader.enable_processing = true
    File.open("spec/support/test.png") { |f| uploader.store!(f) }
  end

  after do
    AvatarUploader.enable_processing = false
    uploader.remove!
  end

  context 'different square sizes' do
    it "scales down image to be exactly 35 by 35 pixels" do
      expect(uploader.sq35).to have_dimensions(35, 35)
    end

    it "scales down image to be exactly 100 by 100 pixels" do
      expect(uploader.sq100).to have_dimensions(100, 100)
    end

    it "scales down image to be exactly 200 by 200 pixels" do
      expect(uploader.sq200).to have_dimensions(200, 200)
    end
  end

  context 'different width sizes' do
    it "scales down image to be 100 pixels wide" do
      expect(uploader.w100).to have_width(100)
    end

    it "scales down image to be 200 pixels wide" do
      expect(uploader.w200).to have_width(200)
    end

    it "scales down image to be 300 pixels wide" do
      expect(uploader.w300).to have_width(300)
    end
  end

  it "has the correct format" do
    expect(uploader).to be_format('png')
  end
end