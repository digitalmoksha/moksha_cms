require 'spec_helper'

include DmCore::AccountHelper

describe DmCore::AccountHelper do
  setup_account

  #------------------------------------------------------------------------------
  it "returns the current account" do
    expect(current_account).to eq Account.current
  end

  #------------------------------------------------------------------------------
  it "returns the account prefix" do
    expect(account_prefix).to eq 'test'
  end

  #------------------------------------------------------------------------------
  it "returns path to the site's general assets" do
    expect(account_site_assets).to eq '/site_assets/content/test'
    expect(account_site_assets(false)).to eq 'site_assets/content/test'
  end

  #------------------------------------------------------------------------------
  it "returns path to the site's upload directory" do
    expect(account_site_assets_uploads).to eq '/site_assets/uploads/test'
    expect(account_site_assets_uploads(false)).to eq 'site_assets/uploads/test'
  end

  #------------------------------------------------------------------------------
  it "returns path to the site's protected assets media folder" do
    expect(account_protected_assets_media_folder).to eq "#{Rails.root}/protected_assets/uploads/test/media"
  end

  #------------------------------------------------------------------------------
  it "returns the path of the site's media folder" do
    expect(account_site_assets_media).to eq '/site_assets/uploads/test/media'
    expect(account_site_assets_media(false)).to eq 'site_assets/uploads/test/media'
  end

  #------------------------------------------------------------------------------
  it "returns url to the site's general assets" do
    expect(account_site_assets_url).to eq 'http://test.example.com/site_assets/content/test'
  end

  # Returns the path (from the root of the site) to the site general asset files
  #   Pass in false not to include leading slash
  #------------------------------------------------------------------------------
  it "returns url to the site's media assets" do
    expect(account_site_assets_media_url).to eq 'http://test.example.com/site_assets/uploads/test/media'
  end
end